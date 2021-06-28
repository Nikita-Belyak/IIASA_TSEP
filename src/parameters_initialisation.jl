using CSV, DataFrames
## defining parameters 

src_link  =  "/Users/nikitabelyak/Dropbox (Aalto)/IIASA/TSEP"
cd(src_link)
using Pkg
Pkg.activate(".")

## Sets and indices 

# nodes 
Nodes = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/" * "sets.csv"))[!,1]))
N_nodes = length(Nodes)

# scenarios probabilities
S_prob = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/" * "sets.csv"))[!,2]))
N_scen = length(S_prob)

# time periods 
T = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/" * "sets.csv"))[!,3]))
N_t = length(T)


## Transmission lines parameters 

# current capacities 
L_max = Matrix(DataFrame(CSV.File(src_link * "/data/transmission_lines/" * "lines_capacity.csv"))[!,:])

# maintenance costs 
M_lines = Matrix(DataFrame(CSV.File(src_link * "/data/transmission_lines/" * "lines_maintenance_cost.csv"))[!,:])

# transmission costs 
C_lines = Matrix(DataFrame(CSV.File(src_link * "/data/transmission_lines/" * "lines_transmission_cost.csv"))[!,:])

# investment costs (considering the expansion)
I_lines = Matrix(DataFrame(CSV.File(src_link * "/data/transmission_lines/" * "lines_capacity_expansion_cost.csv"))[!,:])


## Power generation parameters

# table for maximum generation capacity at each node for conventional energy
g_max_conv = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/generation_units/" * "generation_capacites.csv"))[!,4]))

# table for maximum generation capacity at each node for VRES
g_max_VRES = Matrix(DataFrame(CSV.File(src_link * "/data/generation_units/" * "generation_capacites.csv"))[!,2:3])

# maintenace cost at each node for conventional units 
M_conv = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/generation_units/" * "maintenance_costs.csv"))[!,4])) 

# maintenace cost at each node for VRES
M_VRES = Matrix(DataFrame(CSV.File(src_link * "/data/generation_units/" * "maintenance_costs.csv"))[!,2:3])

# operational costs at each node for conventional units 
C_conv = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/generation_units/" * "operational_costs.csv"))[!,2])) 

# Ramping parameters
# ramp up limit as a share of total installed capacity R_up(u)
R_up = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/generation_units/" * "R_up.csv"))[!,2]))  

# ramp down limit as a share of total installed capacity R_down(u)
R_down = collect(skipmissing(DataFrame(CSV.File(src_link * "/data/generation_units/" * "R_down.csv"))[!,2])) 

## Demand and price parameters
epsilon = -0.3 

t_p_ref = convert(Matrix{Int}, CSV.read("t_p_ref.csv"))[Mn,Nn] #reference price for demand function t_p_ref(m,n)
p_ref= t_p_ref # reference price for demand function (m,n)
q_ref = t_q_ref # reference power demand t_q_ref(m,n,t)
dem_slp = [q_ref[m,n,t]!=0 && - p_ref[m,n] / ( epsilon * q_ref[m,n,t]) for m in Mn, t in Tn, n in Nn] #inverse demand function slope dem_slp(m,t,n)
dem_int = [q_ref[m,n,t]!=0 && p_ref[m,n] + q_ref[m,n,t] * dem_slp[m,t,n] for m in Mn, t in Tn, n in Nn] #inverse demand function intercept dem_int(m,t,n)
