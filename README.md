# Knowledge-driven AutoML

This is a repository that contains the knowledge bases and experiments for testing out [Kdautoml.jl](https://github.com/zgornel/Kdautoml.jl)

## Installation
The steps detailed below suppose that one has installed [docker](https://www.docker.com/), [julia](https://julialang.org/) on a unix-like system such as GNU/Linux.

Installation can be performed by:
 - cloning the repository with `git clone https://github.com/zgornel/knowledge-driven-automl/`
 - get the `Kdautoml` sub-module with `cd knowledge-driven-automl && git submodule init && git submodule update dev/Kdautoml`
 - get the [neo4j](https://neo4j.com/) docker image `docker image pull neo4j:4.2.3`
 - install/update all Julia package dependencies `julia --project=dev/Kdautoml -e "using Pkg; Pkg.add(url=\"https://github.com/dpsanders/SatisfiabilityInterface.jl\"); Pkg.update()"`
 - start container for pipeline synthesis knowledge base. On the first run, the container script should be run:
   ```
   ./docker/start_pipesynthesis_container.sh
   ```
   Subsequently, one can start the container with `docker start neo4j_pipesynthesis_kb`.
 - start container for feature synthesis knowledge base. On the first run, the container script should be run:
   ```
   ./docker/start_featuresynthesis_container.sh
   ```
   Subsequently, one can start the container with `docker start neo4j_featuresynthesis_kb`.
 - Add the data to the neo4j graph db instances runing in the containers with:
   ```
   julia ./dev/Kdautoml/scripts/fill_pipesynthesis_kb.jl ./data/knowledge/pipe_synthesis.toml &&
   julia ./dev/Kdautoml/scripts/fill_featuresynthesis_kb.jl ./data/knowledge/feature_synthesis.toml
   ```

## Reproducing the experimeriments for KAIS (Knowledge and Information Systems) journal
The experiments need different knowledge bases from the 'generic' ones present in `data/knowledge`

### 'XOR' experiment
The 'XOR' problem experiment uses a different feature synthesis kb which has to be imported:
```
julia ./dev/Kdautoml/scripts/fill_featuresynthesis_kb.jl ./experiments/KAIS/xor-dataset-expriment-1/feature_synthesis_xor_usecase.toml
```

The pipeline synthesis knowledge base remains the one present in `data/knowledge/pipe_synthesis.toml`. One can run the experiment with:
```
./experiments/KAIS/xor-dataset-expriment-1/build_pipes_xor_usecase.jl
```

### 'Circles' experiment
The 'Circles' dataset experiment uses a different pipeline synthesis kb which has to be imported:
```
julia ./dev/Kdautoml/scripts/fill_pipesynthesis_kb.jl ./experiments/KAIS/circles-dataset-experiment-2/pipe_synthesis_circles_usecase.toml
```

The feature synthesis knowledge base remains the one present in `data/knowledge/feature_synthesis.toml`. One can run the experiment with:
```
./experiments/KAIS/circles-dataset-experiment-2/build_pipes_circles_usecase.jl
```


## Printing or accessing the experimental results
Once an experiment job finishes, the results are serialized in the current directory in a file called either `_results_xor_experiment.bin` or `_results_circles_experiment.bin` respectively. The `print_results.jl` scripts corrsponding to each experiment can be ran to print the pipeline space or pipeline space statistics extracted from the serialized data. The file also provides insights into how to access the results. The `.bin` file needs to be in the same directory as the `print_results.jl` file.


## Monitoring the pipeline space growth
Monitoring the pipeline building progress (pipeline space evolution) can be done with
`watch -n 0.1 cat __tree__` where `__tree__` is a file that is iteratively updated with a printout of the state of the pipelines during synthesis.

## License
This code GPL v3, see `LICENSE.md`.

## Publication
The associated paper is ["A knowledge-driven AutoML architecture" (arxiv)](https://arxiv.org/abs/2311.17124). Cite as:
```
@misc{cofaru2023knowledgedriven,
  title={A knowledge-driven AutoML architecture},
  author={Corneliu Cofaru and Johan Loeckx},
  year={2023},
  eprint={2311.17124},
  archivePrefix={arXiv},
  primaryClass={cs.LG}
}
```

## Reporting Bugs
At the moment the code is under heavy development and much of the API and features are subject to change ¯\\_(ツ)_/¯. Please [file an issue](https://github.com/zgornel/knowledge-driven-automl/issues/new) to report a bug or request a feature.
