#!/bin/julia

# This file is ment to be run from its own directory
using Serialization
using Pkg

using Logging
global_logger(ConsoleLogger(stdout, Logging.Info))

Pkg.activate(joinpath(dirname(@__FILE__), "../../../dev/Kdautoml/"))
using Kdautoml

### open("__log__", "w") do io
### logger = SimpleLogger(io, Logging.Debug)
### global_logger(logger)

kbpath = joinpath(dirname(@__FILE__), "../../../data/knowledge/pipe_synthesis.toml")
@info "Loading KB at $kbpath"
kb = Kdautoml.kb_load(kbpath)

# Declare and initialize program
pipes = Kdautoml.Pipelines(;backend=:Dagger)  # header is automaticall added

# Define transition clojure to provide kb and program
primed_transition = (args...)->Kdautoml.transition(args...; kb=kb, pipelines=pipes)

# Build pipelines
csvpath = joinpath(dirname(@__FILE__), "xor_10x10.tsv")
dfs_args = ("\"$(joinpath(dirname(@__FILE__), "feature_synthesis_xor_usecase.toml"))\"", 1, true)  # kb path, max_depth, calculate
components= [
             Kdautoml.LoadData((arguments=(true, "\"$(csvpath)\"", "'\t'"), execute=true)),
             Kdautoml.PreprocessData((arguments=([1,2],), execute=true,)),
             #Kdautoml.SplitCV((arguments=(3, true), execute=true)),
             Kdautoml.SplitHoldout((arguments=(0.5, true), execute=true)),
             Kdautoml.DFS((arguments=dfs_args, execute=true)),  # can be transformation, generation or selection
             Kdautoml.FeatureSelection((arguments=("random", 5, 2), execute=true)),  # 3-subsets, 2 features each
             Kdautoml.SelectModel((execute=true, preconditions=(:DataPrecondition, :PipelinePrecondition, :InputPrecondition))),
             Kdautoml.ModelData((execute=true,)),
             Kdautoml.EvalModel((arguments=(:accuracy,), execute=true,))
            ]

#Check first
#@assert reduce(Kdautoml._transition, components; init=Kdautoml.NoData(nothing)) isa Kdautoml.End{Nothing}

endstate = reduce(primed_transition, components, init=Kdautoml.NoData(nothing))

open("_results_xor_experiment.bin", "w") do io
    serialize(io, pipes)
end

### end
