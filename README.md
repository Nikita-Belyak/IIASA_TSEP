The repository contains the implementtion of the TSEP considering the possibility to expand the VRES and conventional generation capacity in addition to lines. 

The code contains the following functions 

```julia
function single_level_problem_generation(ip::initial_parameters)    
```
and

```julia
function bi_level_problem_generation(ip::initial_parameters, market::String)    
```
That generates the centralised single-level model or bi-level respectfully. 

The parameter __ip__  is a structure that stores attributes for generating JuMP model with the following fileds 
initial_parameters

* num_scen::Int                                     Number of scenarios used in the model
* num_nodes::Int                                    Number of nodes in the model
* num_time_periods::Int                             Number of time periods used in the model 
* num_VRES::Int                                     Number of types of VRES sources
* num_conv::Int                                     Number of types of conventional sources
* num_prod::Int                                     Number of energy producer 
* scen_prob::Vector{Float64}                        Vector of probabilities associated with each scenario
* time_periods::Vector{Float64}                     Vector of the time periods values (h)
* id_slope::Array{Float64}                          Slope of the inverse demand function
* id_intercept::Array{Float64}                      Intercept of the inverse demand function
* vres::VRES_parameters                             VRES related parameters
* conv::conventional_generation_parameters          Conventional generation related parameters 
* transm::transmission_parameters                   Transmission lines related paramters

And the paramter __market__ is string variable that takes values "perfect" or "cournot" inidicating whther we should conisder perfect comptetion or the cournout ologopoly between investors at the lower level. 

The main code including all the correspondent packages and files islocated in the file experiments.jl. 

To run the code change the string file
src_link  ="/Users/nikitabelyak/Dropbox (Aalto)/IIASA/TSEP" to point to a link to the location of the repository on your local device. 

