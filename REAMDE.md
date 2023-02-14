# Knowledge-driven AutoML

This is a repository that contains the knowledge bases and experimetal scripts for testing out [Kdautoml.jl](https://gitlab.ai.vub.ac.be/applied-projects/Kdautoml.jl)

## Installation
The steps detailed below suppose that one has installed [docker](https://www.docker.com/), [julia](https://julialang.org/) on a unix-like system such as GNU/Linux.

Installation can be performed by:
 - cloning the repository with `git clone https://gitlab.ai.vub.ac.be/ccofaru/knowledge-driven-automl`
 - get the `Kdautoml` sub-module with `cd knowledge-driven-automl && git submodule init && git submodule update dev/Kdautoml`
 - get the [neo4j](https://neo4j.com/) docker image `docker image pull neo4j:4.2.3`
 - install/update all Julia package dependencies `julia --project=dev/Kdautoml -e "using Pkg; Pkg.add(url=\"https://github.com/dpsanders/SatisfiabilityInterface.jl\"); Pkg.update()"`
 - start container for pipeline synthesis knowledge base (replace `$FULL_PATH` with the actual full path to the current folder):
   ```
   docker run \
    --detach \
    --publish=7475:7474 \
    --publish=7687:7687 \
    --volume=$FULL_PATH/knowledge-driven-automl/data/db/neo4j_pipesynthesis_kb/data/:/data \
    --volume=$FULL_PATH/knowledge-driven-automl/data/db/neo4j_pipesynthesis_kb/logs:/logs \
    --volume=$FULL_PATH/knowledge-driven-automl/data/db/neo4j_pipesynthesis_kb/import:/var/lib/neo4j/import \
    --volume=$FULL_PATH/knowledge-driven-automl/data/db/neo4j_pipesynthesis_kb/import:/var/lib/neo4j/import \
    --volume=$FULL_PATH/knowledge-driven-automl/data/db/neo4j_pipesynthesis_kb/conf:/conf \
    --env NEO4J_dbms_memory_pagecache_size=4G \
    --env NEO4J_AUTH=neo4j/test \
    --name neo4j_pipesynthesis_kb \
    neo4j:4.2.3
   ```
 - start container for feature synthesis knowledge base (replace `$FULL_PATH` with the actual full path to the current folder):
   ```
   docker run \
    --detach \
    --publish=7475:7474 \
    --publish=7688:7687 \
    --volume=$FULL_PATH/knowledge-driven-automl/data/db/neo4j_featuresynthesis_kb/data/:/data \
    --volume=$FULL_PATH/knowledge-driven-automl/data/db/neo4j_featuresynthesis_kb/logs:/logs \
    --volume=$FULL_PATH/knowledge-driven-automl/data/db/neo4j_featuresynthesis_kb/import:/var/lib/neo4j/import \
    --volume=$FULL_PATH/knowledge-driven-automl/data/db/neo4j_featuresynthesis_kb/import:/var/lib/neo4j/import \
    --volume=$FULL_PATH/knowledge-driven-automl/data/db/neo4j_featuresynthesis_kb/conf:/conf \
    --env NEO4J_dbms_memory_pagecache_size=4G \
    --env NEO4J_AUTH=neo4j/test \
    --name neo4j_featuresynthesis_kb \
    neo4j:4.2.3
   ```
 - NOTE: Containers can be restarted using their name onlu i.e. `docker start neo4j_pipesynthesis_kb`
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


## Monitoring the pipeline space growth
Monitoring the pipeline building progress (pipeline space evolution) can be done with
`watch -n 0.1 cat __tree__` where `__tree__` is a file that is iteratively updated with a printout of the state of the pipelines during synthesis.

## License
This code GPL v3, see `LICENSE.md`.


## Reporting Bugs
At the moment the code is under heavy development and much of the API and features are subject to change ¯\\_(ツ)_/¯. Please [file an issue](https://gitlab.ai.vub.ac.be/ccofaru/knowledge-driven-automl/-/issues/new) to report a bug or request a feature.
