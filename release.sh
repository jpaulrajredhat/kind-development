#!/usr/bin/env bash

# Safeties on: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail
# docker login quay.io -u '<username>' -p 'passpwrd'

# DEFAULT_TAG=quay.io/osclimate/localairflow:1.2
# DEFAULT_TAG=osclimate/trino:1.1
AIRFLOW_TAG=osclimate/airflow:2.9.4
TRINO_TAG=osclimate/trino:1.0
MINIO_TAG=osclimate/minio:1.0
# DEFAULT_TAG=osclimate/minio:1.0
# TAG=${TAG:-$DEFAULT_TAG}

docker buildx ls | grep multiarch || docker buildx create --name multiarch --use

docker buildx build  \
    --platform linux/arm64 \
    --tag "$AIRFLOW_TAG" \
    --load \
    .

docker buildx build  \
    -f Dockerfile-trino \
    --platform linux/arm64 \
    --tag "$TRINO_TAG" \
    --load \
    .

docker buildx build  \
    -f Dockerfile-minio \
    --platform linux/amd64 \
    --tag "$MINIO_TAG" \
    --load \
    .

# docker buildx build  \
#     -f Dockerfile-trino \
#     --platform linux/amd64 \
#     --tag "$TRINO_TAG" \
#     --load \
#     .

# docker buildx build  \
#     -f Dockerfile-minio \
#     --platform linux/amd64 \
#     --load \
#     --tag "$MINIO_TAG" \
#     .
# docker buildx build --push \
#     --platform linux/arm64,linux/amd64 \
#     --tag "$TAG" \
#     .