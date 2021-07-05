src_link  =  "/Users/nikitabelyak/Dropbox (Aalto)/IIASA/TSEP"
cd(src_link)
using Pkg
Pkg.activate(".")
using CSV, DataFrames, JuMP, Gurobi

# set unique envinronment for Gurobi
#const GRB_ENV = Gurobi.Env()


include(src_link*"/src/types/parameters.jl")
include(src_link*"/src/utils/parameters_initialisation.jl")
include(src_link*"/src/utils/models_generation.jl")

single_level_problem = single_level_problem_generation(input_parameters)