#!/bin/julia

# This file is ment to be run from its own directory
using Serialization
using Pkg

using Logging
global_logger(ConsoleLogger(stdout, Logging.Info))

Pkg.activate(joinpath(dirname(@__FILE__), "../../../dev/Kdautoml/"))
using Kdautoml

kbpath = joinpath(dirname(@__FILE__), "./pipe_synthesis_circles_usecase.toml")
@info "Loading KB at $kbpath"
kb = Kdautoml.kb_load(kbpath)

# Build pipelines
csvpath = joinpath(dirname(@__FILE__), "circle_2_1000.tsv")


# Define components for pipelines
generate_comps(;preconditions=(:DataPrecondition, :PipelinePrecondition, :InputPrecondition)) = begin
    return Dict(
        :comps_CLF => [
                     Kdautoml.LoadData((arguments=(true, "\"$(csvpath)\"", "'\t'"), execute=true)),
                     Kdautoml.PreprocessData((arguments=([1,2],), execute=true,)),
                     Kdautoml.SplitHoldout((arguments=(0.5, true), execute=true)),
                     Kdautoml.SelectModel((execute=true, preconditions=preconditions)),
                     Kdautoml.ModelData((execute=true,)),
                     Kdautoml.EvalModel((arguments=(:log_loss,), execute=true,))
                    ],
        :comps_FG_CLF => [
                     Kdautoml.LoadData((arguments=(true, "\"$(csvpath)\"", "'\t'"), execute=true)),
                     Kdautoml.PreprocessData((arguments=([1,2],), execute=true,)),
                     Kdautoml.SplitHoldout((arguments=(0.5, true), execute=true)),
                     Kdautoml.FeatureGeneration((arguments=(), execute=true, preconditions=preconditions)),  # can be transformation, generation or selection
                     Kdautoml.SelectModel((execute=true, preconditions=preconditions)),
                     Kdautoml.ModelData((execute=true,)),
                     Kdautoml.EvalModel((arguments=(:log_loss,), execute=true,))
                    ],
        :comps_DR_CLF => [
                     Kdautoml.LoadData((arguments=(true, "\"$(csvpath)\"", "'\t'"), execute=true)),
                     Kdautoml.PreprocessData((arguments=([1,2],), execute=true,)),
                     Kdautoml.SplitHoldout((arguments=(0.5, true), execute=true)),
                     Kdautoml.DimensionalityReduction((arguments=(), execute=true, preconditions=preconditions)),
                     Kdautoml.SelectModel((execute=true, preconditions=preconditions)),
                     Kdautoml.ModelData((execute=true,)),
                     Kdautoml.EvalModel((arguments=(:log_loss,), execute=true,))
                    ],
        :comps_FG_DR_CLF => [
                     Kdautoml.LoadData((arguments=(true, "\"$(csvpath)\"", "'\t'"), execute=true)),
                     Kdautoml.PreprocessData((arguments=([1,2],), execute=true,)),
                     Kdautoml.SplitHoldout((arguments=(0.5, true), execute=true)),
                     Kdautoml.FeatureGeneration((arguments=(), execute=true, preconditions=preconditions)),  # can be transformation, generation or selection
                     Kdautoml.DimensionalityReduction((arguments=(), execute=true, preconditions=preconditions)),
                     Kdautoml.SelectModel((execute=true, preconditions=preconditions)),
                     Kdautoml.ModelData((execute=true,)),
                     Kdautoml.EvalModel((arguments=(:log_loss,), execute=true,))
                    ],
        :comps_FG_FG_DR_CLF => [
                     Kdautoml.LoadData((arguments=(true, "\"$(csvpath)\"", "'\t'"), execute=true)),
                     Kdautoml.PreprocessData((arguments=([1,2],), execute=true,)),
                     Kdautoml.SplitHoldout((arguments=(0.5, true), execute=true)),
                     Kdautoml.FeatureGeneration((arguments=(), execute=true, preconditions=preconditions)),  # can be transformation, generation or selection
                     Kdautoml.FeatureGeneration((arguments=(), execute=true, preconditions=preconditions)),  # can be transformation, generation or selection
                     Kdautoml.DimensionalityReduction((arguments=(), execute=true, preconditions=preconditions)),
                     Kdautoml.SelectModel((execute=true, preconditions=preconditions)),
                     Kdautoml.ModelData((execute=true,)),
                     Kdautoml.EvalModel((arguments=(:log_loss,), execute=true,))
                    ]
    )
end

using AbstractTrees

get_num_pipes(pipes) = begin
	leaves = map(n->n.id, collect(Leaves(pipes.tree)))
    return length(leaves)
end

get_errors(pipes) = begin
	leaves = map(n->n.id, collect(Leaves(pipes.tree)))
    return float.(pipes.artifacts[l].evaluation.measurement for l in leaves if pipes.artifacts[l]!=nothing)
end

get_num_failed(pipes) = begin
	leaves = map(n->n.id, collect(Leaves(pipes.tree)))
    return length([pipes.artifacts[l] for l in leaves if pipes.artifacts[l]==nothing])
end

results=Dict()
for (_name, _comps) in generate_comps(preconditions=(:DataPrecondition, :PipelinePrecondition, :InputPrecondition))
    pipes = Kdautoml.Pipelines(;backend=:Dagger)  # header is automaticall added
    primed_transition = (args...)->Kdautoml.transition(args...; kb=kb, pipelines=pipes)
    reduce(primed_transition, _comps, init=Kdautoml.NoData(nothing))
	leaves = map(n->n.id, collect(Leaves(pipes.tree)))
	push!(results, _name=>(number=get_num_pipes(pipes),
                           err=get_errors(pipes),
                           failed=get_num_failed(pipes)))
end


results_no_dp=Dict()
for (_name, _comps) in generate_comps(preconditions=(:PipelinePrecondition, :InputPrecondition))
    pipes = Kdautoml.Pipelines(;backend=:Dagger)  # header is automaticall added
    primed_transition = (args...)->Kdautoml.transition(args...; kb=kb, pipelines=pipes)
    reduce(primed_transition, _comps, init=Kdautoml.NoData(nothing))
	leaves = map(n->n.id, collect(Leaves(pipes.tree)))
	push!(results_no_dp, _name=>(number=get_num_pipes(pipes),
                                 err=get_errors(pipes),
                                 failed=get_num_failed(pipes)))
end

open("_results_circles_experiment.bin", "w") do io
    serialize(io, (results, results_no_dp))
end
