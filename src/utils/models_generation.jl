function single_level_problem_generation(ip::initial_parameters)    
    # Defining single-level model
    single_level_problem = Model(() -> Gurobi.Optimizer(GRB_ENV))
    set_optimizer_attribute(single_level_problem, "OutputFlag", 0)

    ## VARIABLES

    # Conventional generation related variable
    @variable(single_level_problem, g_conv[1:ip.num_scen, 1:ip.num_time_periods, 1:ip.num_nodes, 1:ip.num_prod, 1:ip.num_conv] >= 0)

    # VRES generation related variable
    @variable(single_level_problem, g_VRES[1:ip.num_scen, 1:ip.num_time_periods, 1:ip.num_nodes, 1:ip.num_prod, 1:ip.num_VRES] >= 0)

    # Consumption realted variable
    @variable(single_level_problem, q[1:ip.num_scen, 1:ip.num_time_periods, 1:ip.num_nodes])

    # Energy transmission realted variable
    @variable(single_level_problem, f[1:ip.num_scen, 1:ip.num_time_periods, 1:ip.num_nodes, 1:ip.num_nodes] >= 0)

    # Transmission capacity expansion realted variable
    @variable(single_level_problem, l_plus[ 1:ip.num_nodes, 1:ip.num_nodes]>=0)

    # Conventional energy capacity expansion realted variable
    @variable(single_level_problem, g_conv_plus[ 1:ip.num_nodes, 1:ip.num_prod, 1:ip.num_conv]>=0)

    # VRES capacity expansion realted variable
    @variable(single_level_problem, g_VRES_plus[ 1:ip.num_nodes, 1:ip.num_prod, 1:ip.num_VRES]>=0)

    ## OBJECTIVE
    @objective(single_level_problem, Max, 
            sum(
                sum( ip.scen_prob[s] * 

                    (ip.id_intercept[s,t,n]*q[s,t,n] 
                    - 0.5* ip.id_slope[s,t,n]* q[s,t,n]^2
                    
                    - sum( 
                        (ip.conv.operational_costs[n,i,e] 
                        + ip.conv.CO2_tax[e])*g_conv[s,t,n,i,e] 
                    for i in 1:ip.num_prod, e in 1:ip.num_conv)

                    - sum(ip.transm.transmissio_costs[n,m]*f[s,t,n,m] 
                    for n in 1:ip.num_nodes, m in 1:ip.num_nodes)
                    )

                for t in 1:ip.num_time_periods, s in 1:ip.num_scen)
                
                -sum( 

                    sum( 
                        ip.vres.maintenance_costs[n,i,r]*
                        (ip.vres.installed_capacities[n,i,r] + g_VRES_plus[n,i,r]) 
                        + 
                        ip.vres.investment_costs[n,i,r]*g_VRES_plus[n,i,r]
                    for r in 1:ip.num_VRES)
                    
                    +
                        
                    sum( 
                        ip.conv.maintenance_costs[n,i,e]*
                        (ip.conv.installed_capacities[n,i,e] + g_conv_plus[n,i,e]) 
                        + 
                        ip.conv.investment_costs[n,i,e]*g_conv_plus[n,i,e]
                    for e in 1:ip.num_conv) 
                         
                for i in 1:ip.num_prod)
                
                - sum(

                    ip.transm.maintenance_costs[n,m]*
                    (ip.transm.installed_capacities[n,m] + l_plus[n,m])
                    +
                    ip.transm.investment_costs[n,m]*l_plus[n,m]

                for m in ip.num_nodes)
            
            for n in ip.num_nodes )
    )

    ## CONSTRAINTS

    # Power balance
    @constraint(single_level_problem, [s in 1:ip.num_scen, t in 1:ip.num_time_periods, n in 1:ip.num_nodes],
        q[s,t,n] == sum( 
                        sum(g_conv[s,t,n,i,e] for e in 1:ip.num_conv)    
                         + 
                        sum(g_VRES[s,t,n,i,r] for r in 1:ip.num_VRES) 
                        for i = 1:ip.num_prod)
                    - sum( f[s,t,n,m] for m in 1:ip.num_nodes) + sum( f[s,t,m,n] for m in 1:ip.num_nodes)
    )

    # Transmission bounds 
    @constraint(single_level_problem, [s in 1:ip.num_scen, t in 1:ip.num_time_periods, n in 1:ip.num_nodes, m in 1:ip.num_nodes ],
        f[s,t,n,m] - ip.time_periods[t]*(ip.transm.installed_capacities[n,m] + l_plus[n,m]) <= 0
    )

    # Primal feasibility for the transmission 
    @constraint(single_level_problem, [s in 1:ip.num_scen, t in 1:ip.num_time_periods, n in 1:ip.num_nodes],
        f[s,t,n,n] == 0 
    )

    # Conventional generation bounds
    @constraint(single_level_problem, [ s in 1:ip.num_scen, t in 1:ip.num_time_periods, n in 1:ip.num_nodes, i = 1:ip.num_prod, e in 1:ip.num_conv],
        g_conv[s,t,n,i,e] - ip.time_periods[t]*(ip.conv.installed_capacities[n,i,e] + g_conv_plus[n,i,e]) <= 0
    )
    # VRES generation bounds 
    @constraint(single_level_problem, [ s in 1:ip.num_scen, t in 1:ip.num_time_periods, n in 1:ip.num_nodes, i = 1:ip.num_prod, r in 1:ip.num_VRES],
        g_VRES[s,t,n,i,r] - ip.time_periods[t]*(ip.vres.installed_capacities[n,i,r] + g_VRES_plus[n,i,r]) <= 0
    )

    # Maximum ramp-up rate for conventional units
    @constraint(single_level_problem, [ s in 1:ip.num_scen, t in 1:ip.num_time_periods, n in 1:ip.num_nodes, i = 1:ip.num_prod, e in 1:ip.num_conv],
        g_conv[s,t,n,i,e] - (t == 1 ? 0 : g_conv[s,t-1,n,i,e]) - ip.time_periods[t] * ip.conv.ramp_up[n,i,e] * (ip.conv.installed_capacities[n,i,e] + g_conv_plus[n,i,e]) <= 0
    )

    # Maximum ramp-down rate for conventional units
    @constraint(single_level_problem, [ s in 1:ip.num_scen, t in 1:ip.num_time_periods, n in 1:ip.num_nodes, i = 1:ip.num_prod, e in 1:ip.num_conv],
        (t == 1 ? 0 : g_conv[s,t-1,n,i,e]) - g_conv[s,t,n,i,e] - ip.time_periods[t] * ip.conv.ramp_down[n,i,e] * (ip.conv.installed_capacities[n,i,e] + g_conv_plus[n,i,e]) <= 0
    )
    
    return single_level_problem
end