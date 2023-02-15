#!/usr/bin/julia
#
using Pkg
Pkg.activate(joinpath(dirname(@__FILE__), "../../../dev/Kdautoml/"))
using AbstractTrees
using MLJ, MLJLIBSVMInterface, MLJXGBoostInterface, MLJMultivariateStatsInterface
using Serialization
using Revise
using Kdautoml

using Logging
global_logger(ConsoleLogger(stdout, Logging.Info))

pipes = open(joinpath(dirname(@__FILE__), "_results_xor_experiment.bin")) do io
    deserialize(io)
end
Kdautoml.print_tree_debug(pipes.tree, maxdepth=10)
leaves = map(n->n.id, collect(Leaves(pipes.tree)))
for l in leaves
    if pipes.artifacts[l] != nothing
        @show l, pipes.artifacts[l].evaluation
    else
        @show l, "Pipeline evaluation data missing..."
    end
end
