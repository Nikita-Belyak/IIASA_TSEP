## defining parameters 

## Sets and indices 

# Nodes 
Nodes = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/" * "sets.csv"))[!,1]))
N_nodes = length(Nodes)

# Scenarios probabilities
S_prob = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/" * "sets.csv"))[!,2]))
N_scen = length(S_prob)

# Time periods 
T = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/" * "sets.csv"))[!,3]))
N_T = length(T)

# VRES sources 
R = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/" * "sets.csv"))[!,4]))
N_R = length(R)

# Conventional sources 
E = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/" * "sets.csv"))[!,5]))
N_E = length(E)

# Producers 
I = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/" * "sets.csv"))[!,6]))
N_I = length(I)


## Demand 

# Slope of the inverse demand functoion
id_slope = Array{Float64}(undef, N_scen, N_T, N_nodes) 
for s = 1:N_scen
    id_slope[s, :, :] = Matrix(DataFrame(CSV.File(src_link * "/data/inverse_demand/inverse_demand_slope/" * "inverse_demand_slope_scenario_"*string(s)*".csv"))[!,2:N_nodes+1])
end

# intercept of the inverse demand functoion
id_intercept = Array{Float64}(undef, N_scen, N_T, N_nodes) 
for s = 1:N_scen
    id_intercept[s, :, :] = Matrix(DataFrame(CSV.File(src_link * "/data/inverse_demand/inverse_demand_intercept/" * "inverse_demand_intercept_scenario_"*string(s)*".csv"))[!,2:N_nodes+1])
end

## Transmission lines parameters 

# Installed capacities 
L_max = Matrix(DataFrame(CSV.File(src_link * "/data/transmission_lines/" * "lines_capacity.csv"))[!,:])

# Maintenance costs 
M_lines = Matrix(DataFrame(CSV.File(src_link * "/data/transmission_lines/" * "lines_maintenance_cost.csv"))[!,:])

# Transmission costs 
C_lines = Matrix(DataFrame(CSV.File(src_link * "/data/transmission_lines/" * "lines_transmission_cost.csv"))[!,:])

# Investment costs (considering the expansion)
I_lines = Matrix(DataFrame(CSV.File(src_link * "/data/transmission_lines/" * "lines_capacity_expansion_cost.csv"))[!,:])

TRANSM = transmission_parameters(L_max, M_lines, I_lines,  C_lines)

## Conventional generation

# Maximum generation capacity at each node for conventional energy
G_max_E = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    G_max_E[:,i,:] = Matrix(DataFrame(CSV.File(src_link * "/data/conventional_generation_units/generation_capacities/" * "generation_capacities_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Maintenace costs at each node for conventional units 
M_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    M_conv[:,i,:] = Matrix(DataFrame(CSV.File(src_link * "/data/conventional_generation_units/maintenance_costs/" * "maintenance_costs_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Operational costs at each node for conventional units 
C_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    C_conv[:,i,:] = Matrix(DataFrame(CSV.File(src_link * "/data/conventional_generation_units/operational_costs/" * "operational_costs_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Investment costs at each node for conventional units 
I_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    I_conv[:,i,:] = Matrix(DataFrame(CSV.File(src_link * "/data/conventional_generation_units/investment_costs/" * "investment_costs_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Maximum ramp-up rate for conventional units 
R_up_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    R_up_conv[:,i,:] = Matrix(DataFrame(CSV.File(src_link * "/data/conventional_generation_units/ramp_up/" * "ramp_up_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Maximum ramp-down rate for conventional units 
R_down_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    R_down_conv[:,i,:] = Matrix(DataFrame(CSV.File(src_link * "/data/conventional_generation_units/ramp_down/" * "ramp_down_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Carbon tax for conventional units 
CO2_tax = Matrix(DataFrame(CSV.File(src_link * "/data/conventional_generation_units/" * "carbon_tax.csv"))[!,2:N_E+1])

CONV = conventional_generation_parameters(G_max_E, M_conv, I_conv , C_conv, R_up_conv, R_down_conv, CO2_tax)

## VRES generation

# Maximum generation capacity at each node for VRES
G_max_VRES = Array{Float64}(undef, N_nodes, N_I, N_R )
for i in 1:N_I
    G_max_VRES[:,i,:] = Matrix(DataFrame(CSV.File(src_link * "/data/VRES_generation_units/generation_capacities/" * "generation_capacities_producer_"* string(i)* ".csv"))[!,2:N_R+1])
end

# Maintenace costs at each node for VRES
M_VRES = Array{Float64}(undef, N_nodes, N_I, N_R )
for i in 1:N_I
    M_VRES[:,i,:] = Matrix(DataFrame(CSV.File(src_link * "/data/VRES_generation_units/maintenance_costs/" * "maintenance_costs_producer_"* string(i)* ".csv"))[!,2:N_R+1])
end

# Investment costs at each node for VRES
I_VRES = Array{Float64}(undef, N_nodes, N_I, N_R )
for i in 1:N_I
    I_VRES[:,i,:] = Matrix(DataFrame(CSV.File(src_link * "/data/VRES_generation_units/investment_costs/" * "investment_costs_producer_"* string(i)* ".csv"))[!,2:N_R+1])
end
# Availability factor 

A_VRES = Array{Float64}(undef, N_scen, N_T, N_nodes, N_R)

for s in 1:N_scen
    for n in 1:N_nodes
        A_VRES[s, :, n, :] = Matrix(DataFrame(CSV.File(src_link * "/data/VRES_generation_units/availability_factor/scenario_"*string(s)* "/node_" *string(n)* ".csv"))[!,2:N_R+1])
    end
end

VRES =  VRES_parameters(G_max_VRES, M_VRES, I_VRES, A_VRES)

input_parameters = initial_parameters(N_scen, N_nodes, N_T, N_R, N_E, N_I, S_prob, T, id_slope, id_intercept, VRES, CONV, TRANSM)


