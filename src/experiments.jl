src_link  ="/Users/nikitabelyak/Dropbox (Aalto)/IIASA/TSEP"
cd(src_link)
using Pkg
Pkg.activate(".")
using CSV, DataFrames, JuMP, Gurobi, PyCall, Plots, Ipopt
np = pyimport("numpy")

# set unique envinronment for Gurobi
const GRB_ENV = Gurobi.Env()

data_src_link  =  src_link * "/data/3_nodes_instance"
include(src_link*"/src/utils/data_preprocessing_functions.jl")
include(src_link*"/src/types/parameters.jl")
include(src_link*"/src/utils/parameters_initialisation.jl")
include(src_link*"/src/utils/models_generation.jl")

single_level_problem = single_level_problem_generation(input_parameters)
#io = open(data_src_link*"/single_level_problem_generation.txt" ,"w")
#println(io,single_level_problem)
#close(io)
optimize!(single_level_problem)
objective_value(single_level_problem)
value.(single_level_problem[:l_plus])
value.(single_level_problem[:g_VRES_plus])
value.(single_level_problem[:g_conv_plus])
value.(single_level_problem[:q])
value.(single_level_problem[:g_conv])
value.(single_level_problem[:g_VRES])
value.(single_level_problem[:f])

bi_level_problem = bi_level_problem_generation(input_parameters, "cournot")
optimize!(bi_level_problem)
objective_value(bi_level_problem)
value.(bi_level_problem[:l_plus])
value.(bi_level_problem[:g_VRES_plus])
value.(bi_level_problem[:g_conv_plus])
value.(bi_level_problem[:q])
value.(bi_level_problem[:g_conv])
value.(bi_level_problem[:g_VRES])
value.(bi_level_problem[:f])

