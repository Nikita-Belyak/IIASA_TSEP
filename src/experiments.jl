src_link  ="/Users/nikitabelyak/Dropbox (Aalto)/Schools, conferences and grants/IIASA 2021/TSEP"
cd(src_link)
using Pkg
Pkg.activate(".")
using CSV, DataFrames, JuMP, Gurobi, PyCall, Plots, Ipopt, Statistics
np = pyimport("numpy")

# set unique envinronment for Gurobi
const GRB_ENV = Gurobi.Env()

# scaling factor for the monetary parameters 
scaling_factor = 10.0

data_src_link  =  src_link * "/data/3_nodes_instance"
include(src_link*"/src/utils/data_preprocessing_functions.jl")
include(src_link*"/src/types/parameters.jl")
include(src_link*"/src/utils/parameters_initialisation.jl")
include(src_link*"/src/utils/models_generation.jl")
include(src_link*"/src/utils/data_postprocessing_functions.jl")



single_level_problem = single_level_problem_generation(input_parameters)
#io = open(data_src_link*"/single_level_problem_generation.txt" ,"w")
#println(io,single_level_problem)
#close(io)
optimize!(single_level_problem)
objective_value(single_level_problem)
print_output(data_src_link*"/optimisation_results", input_parameters, objective_value(single_level_problem), value.(single_level_problem[:l_plus]), value.(single_level_problem[:g_VRES_plus]) , value.(single_level_problem[:g_conv_plus]), value.(single_level_problem[:g_VRES]), value.(single_level_problem[:g_conv]), value.(single_level_problem[:f]), "single_level", scaling_factor)

bi_level_problem_cournot = bi_level_problem_generation(input_parameters, "cournot")
optimize!(bi_level_problem_cournot)
objective_value(bi_level_problem_cournot)
print_output(data_src_link*"/optimisation_results", input_parameters, objective_value(bi_level_problem_cournot), value.(bi_level_problem_cournot[:l_plus]), value.(bi_level_problem_cournot[:g_VRES_plus]) , value.(bi_level_problem_cournot[:g_conv_plus]), value.(bi_level_problem_cournot[:g_VRES]), value.(bi_level_problem_cournot[:g_conv]), value.(bi_level_problem_cournot[:f]), "bi_level_cournot", scaling_factor)

bi_level_problem_perfect = bi_level_problem_generation(input_parameters, "perfect")
optimize!(bi_level_problem_perfect)
objective_value(bi_level_problem_perfect)
print_output(data_src_link*"/optimisation_results", input_parameters, objective_value(bi_level_problem_perfect), value.(bi_level_problem_perfect[:l_plus]), value.(bi_level_problem_perfect[:g_VRES_plus]) , value.(bi_level_problem_perfect[:g_conv_plus]), value.(bi_level_problem_perfect[:g_VRES]), value.(bi_level_problem_perfect[:g_conv]), value.(bi_level_problem_perfect[:f]), "bi_level_perfect", scaling_factor)