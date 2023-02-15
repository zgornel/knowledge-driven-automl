#!/usr/bin/julia
#
using Pkg
Pkg.activate(joinpath(dirname(@__FILE__), "../../../dev/Kdautoml/"))
using AbstractTrees
using MLJ, MLJLIBSVMInterface, MLJXGBoostInterface, MLJMultivariateStatsInterface
using Serialization
using Revise
using Kdautoml

results, results_no_dp = open(joinpath(dirname(@__FILE__), "_results_circles_experiment.bin")) do io
    deserialize(io)
end
function _preprocess_results(results)
    processed_results = Dict()
    _calculate_max_pipes(symbname) = 3^(length(split(string(symbname), "_"))-1) # each stage has 3 elements
    for (k,v) in results
        push!(processed_results, k=>(n_pipes=v.number, max_n_pipes=_calculate_max_pipes(k),
                                     μ_error=round(mean(v.err)[1], digits=3), σ_error=round(std(v.err)[1],digits=3),
                                     n_failed=v.failed))
    end
    return processed_results
end
presults=_preprocess_results(results)
presults_no_dp = _preprocess_results(results_no_dp)

# Results for
println("**Results when using Data preconditions**")
for (k, v) in presults
   println(k," => ",v)
end
println("**Results without Data preconditions**")
for (k, v) in presults_no_dp
    println(k," => ",v)
end
