## defining parameters 

## Constants
const interest_rate = 0.05
 
## Sets and indices 

# Nodes 
Nodes = collect(skipmissing(DataFrame(CSV.File(data_src_link  * "/sets.csv"))[!,1]))
N_nodes = length(Nodes)

# Days allocted to each scenariio 
S_days = collect(skipmissing(DataFrame(CSV.File(data_src_link  * "/sets.csv"))[!,2]))

# Scenarios probabilities
S_prob = collect(skipmissing(DataFrame(CSV.File(data_src_link  * "/sets.csv"))[!,3]))
N_scen = length(S_prob)

# Time periods 
T = collect(skipmissing(DataFrame(CSV.File(data_src_link  * "/sets.csv"))[!,4]))
N_T = length(T)

# VRES sources 
R = collect(skipmissing(DataFrame(CSV.File(data_src_link  * "/sets.csv"))[!,5]))
N_R = length(R)

# Conventional sources 
E = collect(skipmissing(DataFrame(CSV.File(data_src_link  * "/sets.csv"))[!,6]))
N_E = length(E)

# Producers 
I = collect(skipmissing(DataFrame(CSV.File(data_src_link  * "/sets.csv"))[!,7]))
N_I = length(I)


# variable correspondent to the representative week number if each scenario
# that is used to define the characterisitcs of the scenario 
representative_week = 2

# Hours allocated to each scenaro
hours_for_each_scenario = hours_for_each_scenario_generation(S_days, representative_week)

## Demand 

# Slope and the intercept of the inverse demand functoion
id_slope, id_intercept = lif_slope_and_intercept_generation(data_src_link, N_nodes, N_scen, T, hours_for_each_scenario, scaling_factor)
#id_slope =  id_slope.*1000
#id_intercept = id_intercept.*1000

## Transmission lines parameters 

# Installed capacities 
L_max = Matrix(DataFrame(CSV.File(data_src_link * "/transmission_lines/" * "lines_capacity.csv"))[!,:])

# Costs
Costs_lines = Matrix(DataFrame(CSV.File(data_src_link * "/transmission_lines/" * "lines_costs.csv"))[!,:])

# Converter costs 
Converter_costs_lines = Matrix(DataFrame(CSV.File(data_src_link * "/transmission_lines/" * "lines_converter_costs.csv"))[!,:])

# Distance
Distance_lines = Matrix(DataFrame(CSV.File(data_src_link * "/transmission_lines/" * "lines_distances.csv"))[!,:])

# Lifetime
Lifetime_lines = Matrix(DataFrame(CSV.File(data_src_link * "/transmission_lines/" * "lines_lifetime.csv"))[!,:])

# Investment costs (considering the expansion)
I_lines = equivalent_annual_cost.(float.(Costs_lines .* Distance_lines .+ Converter_costs_lines),
float.(Lifetime_lines), interest_rate) 
I_lines = replace(I_lines, NaN=>0)
I_lines = I_lines./100

#scalling
I_lines = I_lines./scaling_factor
#I_lines = zeros(size(I_lines))

# Budget limits (considering the expansion for each line) 
B_lines = Matrix(DataFrame(CSV.File(data_src_link * "/transmission_lines/" * "budget_limits.csv"))[!,:])

#scalling
B_lines = B_lines./scaling_factor

#@show I_lines
# Maintenance costs 
M_lines = Matrix(DataFrame(CSV.File(data_src_link * "/transmission_lines/" * "lines_maintenance_costs.csv"))[!,:]) .* I_lines
#scalling
M_lines = M_lines./scaling_factor
TRANSM = transmission_parameters(L_max, M_lines, I_lines, B_lines)

## Conventional generation

# Maximum generation capacity at each node for conventional energy
G_max_E = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    G_max_E[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/generation_capacities/" * "generation_capacities_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Maintenace costs at each node for conventional units 
M_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    M_conv[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/fixed_maintenance_costs/" * "fixed_maintenance_costs_producer_"* string(i)* ".csv"))[!,2:N_E+1]) .* 1000
end
#scalling
M_conv = M_conv./scaling_factor

# Fuel costs at each node for conventional units 
Fuel_costs_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    Fuel_costs_conv[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/fuel_costs/" * "fuel_costs_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Technology efficiency at each node for conventional units
Efficiency_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    Efficiency_conv[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/efficiency/" * "efficiency_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end  

# Variable maintenance costs at each node for conventional units
Var_m_costs_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    Var_m_costs_conv[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/variable_maintenance_costs/" * "variable_maintenance_costs_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end  

# Operational costs at each node for conventional units 
C_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
C_conv = Fuel_costs_conv ./ Efficiency_conv .+ Var_m_costs_conv 
#scalling
C_conv = C_conv./scaling_factor

# Investment costs at each node for conventional units 
Investment_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    Investment_conv[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/investment_costs/" * "investment_costs_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# lifetime at each node for conventional units 
Lifetime_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    Lifetime_conv[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/lifetime/" * "lifetime_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Annualised investment costs at each node for conventional units 
I_conv= Array{Float64}(undef, N_nodes, N_I, N_E )
I_conv = equivalent_annual_cost.(Investment_conv .* 1000, Lifetime_conv, interest_rate) 
#scalling 
I_conv = I_conv./scaling_factor

# Budget limits for the conventional units generation expansion (for each node and each producer)
B_conv = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/budget_limits/budget_limits.csv"))[!,2:N_I+1])
#scalling 
B_conv = B_conv./scaling_factor

# Maximum ramp-up rate for conventional units 
R_up_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    R_up_conv[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/ramp_up/" * "ramp_up_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Maximum ramp-down rate for conventional units 
R_down_conv = Array{Float64}(undef, N_nodes, N_I, N_E )
for i in 1:N_I
    R_down_conv[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/ramp_down/" * "ramp_down_producer_"* string(i)* ".csv"))[!,2:N_E+1])
end

# Carbon tax for conventional units 
CO2_tax = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/" * "carbon_tax.csv"))[!,2:N_E+1])
CO2_tax = CO2_tax .* 10
#scalling 
CO2_tax = CO2_tax./scaling_factor
CONV = conventional_generation_parameters(G_max_E, M_conv, I_conv, B_conv, C_conv, R_up_conv, R_down_conv, CO2_tax)

## VRES generation

# Maximum generation capacity at each node for VRES
G_max_VRES = Array{Float64}(undef, N_nodes, N_I, N_R )
for i in 1:N_I
    G_max_VRES[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/VRES_generation_units/installed_generation_capacities/" * "installed_generation_capacities_producer_"* string(i)* ".csv"))[!,2:N_R+1])
end

# Maintenace costs at each node for VRES
M_VRES = Array{Float64}(undef, N_nodes, N_I, N_R )
for i in 1:N_I
    M_VRES[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/VRES_generation_units/maintenance_costs/" * "maintenance_costs_producer_"* string(i)* ".csv"))[!,2:N_R+1]) .* 1000
end
M_VRES = M_VRES./100
#scalling
M_VRES = M_VRES./scaling_factor

# Investment costs at each node for VRES units 
Investment_VRES = Array{Float64}(undef, N_nodes, N_I, N_R )
for i in 1:N_I
    Investment_VRES[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/VRES_generation_units/investment_costs/" * "investment_costs_producer_"* string(i)* ".csv"))[!,2:N_R+1])
end
Investment_VRES = Investment_VRES./100

# lifetime at each node for VRES units 
Lifetime_VRES = Array{Float64}(undef, N_nodes, N_I, N_R)
for i in 1:N_I
    Lifetime_VRES[:,i,:] = Matrix(DataFrame(CSV.File(data_src_link * "/conventional_generation_units/lifetime/" * "lifetime_producer_"* string(i)* ".csv"))[!,2:N_R+1])
end

# Annualised investment costs at each node for VRES units 
I_VRES= Array{Float64}(undef, N_nodes, N_I, N_R )
I_VRES = equivalent_annual_cost.(Investment_VRES .* 1000, Lifetime_VRES, interest_rate) 
#scalling 
I_VRES = I_VRES./scaling_factor

# Budget limits for the VRES units generation expansion (for each node and each producer)
B_VRES = Matrix(DataFrame(CSV.File(data_src_link * "/VRES_generation_units/budget_limits/budget_limits.csv"))[!,2:N_I+1])
#scalling 
B_VRES = B_VRES./scaling_factor

# Availability factor 
A_VRES = availability_factor_generation(data_src_link, N_nodes, N_scen, T, N_R, hours_for_each_scenario)

VRES =  VRES_parameters(G_max_VRES, M_VRES, I_VRES, B_VRES, A_VRES)

input_parameters = initial_parameters(N_scen, N_nodes, N_T, N_R, N_E, N_I, S_prob, T, id_slope, id_intercept, VRES, CONV, TRANSM)