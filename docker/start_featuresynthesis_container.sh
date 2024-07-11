#!/bin/sh
BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )

docker run \
    --detach \
    --publish=7475:7474 \
    --publish=7688:7687 \
    --volume="${BASE_DIR}/data/db/neo4j_featuresynthesis_kb/data/":/data \
    --volume="${BASE_DIR}/data/db/neo4j_featuresynthesis_kb/logs":/logs \
    --volume="${BASE_DIR}/data/db/neo4j_featuresynthesis_kb/import":/var/lib/neo4j/import \
    --volume="${BASE_DIR}/data/db/neo4j_featuresynthesis_kb/conf":/conf \
    --env NEO4J_dbms_memory_pagecache_size=4G \
    --env NEO4J_AUTH=neo4j/test \
    --name neo4j_featuresynthesis_kb \
    neo4j:4.2.3
