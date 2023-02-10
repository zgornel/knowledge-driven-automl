#!/bin/sh
docker run \
    --detach \
    --publish=7474:7474 \
    --publish=7687:7687 \
    --volume=data/db/neo4j_pipesynthesis_kb/data/:/data \
    --volume=data/db/neo4j_pipesynthesis_kb/logs:/logs \
    --volume=data/db/neo4j_pipesynthesis_kb/import:/var/lib/neo4j/import \
    --volume=data/db/neo4j_pipesynthesis_kb/import:/var/lib/neo4j/import \
    --volume=data/db/neo4j_pipesynthesis_kb/conf:/conf \
    --env NEO4J_dbms_memory_pagecache_size=4G \
    --env NEO4J_AUTH=neo4j/test \
    --name neo4j_pipesynthesis_kb \
    neo4j:4.2.3
