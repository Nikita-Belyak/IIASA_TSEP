""" 
function print_output(...) prints the output resutling from the model optimisation 
    in the user friendly format that is further saved in the single_level_problem_output.txt file 
    in the folder specified in the arguments of the function 
Arguments of the function:
* src_link::String:                 The link at which the output .txt file to be stored 
* ip::initial_parameters            Initial parameters of the model 
* l_plus::Array{Float64}            The optimal values the transmission lines capacity expansion 
* g_VRES_plus::Array{Float64}       The optimal values the VRES capacity expansion
* g_conv_plus::Array{Float64}       The optimal values conventional sources capacity expansion
* g_VRES::Array{Float64}            The optimal VRES generation values
* g_conv::Array{Float64}            The optimal convetional sources generation values
* f::Array{Float64}                 The optimal energy flow values
"""


function print_output(src_link::String, ip::initial_parameters, l_plus::Array{Float64}, g_VRES_plus::Array{Float64}, g_conv_plus::Array{Float64}, g_VRES::Array{Float64}, g_conv::Array{Float64}, f::Array{Float64})
    io = open(src_link*"/single_level_problem_output.txt" ,"w")
    println(io, "TRANSMISSION CAPACITY EXPANSION")
    println(io, "\n")
    nodes = string.(1:ip.num_nodes)
    df_transm_exp = DataFrame()
    df_transm_exp.node = nodes
    for n = 1:ip.num_nodes
        insertcols!(df_transm_exp, n+1, "node_$n" => l_plus[n, :] )
    end
    println(io, df_transm_exp)
    println(io, "\n")

    println(io, "VRES CAPACITY EXPANSION")
    println(io, "\n")
    for i = 1:ip.num_prod
        println(io, "PRODUCER $(i)")
        df_VRES_exp = DataFrame()
        df_VRES_exp.node = nodes
        for r in 1:ip.num_VRES
            insertcols!(df_VRES_exp, r+1, "VRES_$r" => g_VRES_plus[:,i,r] )
        end
        println(io, df_VRES_exp)
        println(io, "\n")
    end
    println(io, "\n")

    println(io, "CONV CAPACITY EXPANSION")
    println(io, "\n")
    for i = 1:ip.num_prod
        println(io, "PRODUCER $(i)")
        df_conv_exp = DataFrame()
        df_conv_exp.node = nodes
        for e in 1:ip.num_conv
            insertcols!(df_conv_exp, e+1, "conv_$e" => g_conv_plus[:,i,e] )
        end
        println(io, df_conv_exp)
        println(io, "\n")
    end
    println(io, "\n")

    println(io, "VRES GENERATION")
    println(io, "\n")
    for i = 1:ip.num_prod
        println(io, "PRODUCER $(i)")
        for s = 1:ip.num_scen
            println(io, "scenario $(s)")
            df_VRES = DataFrame()
            df_VRES.node = nodes
            for r in 1:ip.num_VRES
                insertcols!(df_VRES, r+1, "VRES_$r" => vec(sum(g_VRES[s,:,:,i,r], dims = 1)) )
            end
            println(io, df_VRES)
            println(io, "\n")
        end
    end
    println(io, "\n")

    println(io, "CONV GENERATION")
    println(io, "\n")
    for i = 1:ip.num_prod
        println(io, "PRODUCER $(i)")
        for s = 1:ip.num_scen
            println(io, "scenario $(s)")
            df_conv = DataFrame()
            df_conv.node = nodes
            for e in 1:ip.num_conv
                insertcols!(df_conv, e+1, "conv_$e" => vec(sum(g_conv[s,:,:,i,e], dims = 1)) )
            end
            println(io, df_conv)
            println(io, "\n")
        end
    end
    println(io, "\n")

    println(io, "ENERGY FLOW")
    println(io, "\n")
    for n = 1:ip.num_nodes
        for m = n:ip.num_nodes
            println(io, "flow: $n -> $m ")
            df_flow = DataFrame()
            df_flow.scenario = 1:ip.num_scen
            for t in 1:ip.num_time_periods
                insertcols!(df_flow, t+1, "time_$t" => f[:,t,n,m] )
            end
            println(io, df_flow)
            println(io, "\n")

            println(io, "flow: $m -> $n ")
            df_flow = DataFrame()
            df_flow.scenario = 1:ip.num_scen
            for t in 1:ip.num_time_periods
                insertcols!(df_flow, t+1, "time_$t" => f[:,t,m,n] )
            end
            println(io, df_flow)
            println(io, "\n")
        end
    end
    println(io, "\n")

    close(io)
end