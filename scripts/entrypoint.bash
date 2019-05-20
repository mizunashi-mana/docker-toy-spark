#!/usr/bin/env bash

[[ "$DEBUG" == "true" ]] && set -x
[[ "$STRICT" == "true" ]] && set -u
set -eo pipefail

case ${1} in
  master)
    shift 1
    exec "${SPARK_INSTALL_DIR}/bin/spark-class" "org.apache.spark.deploy.master.Master" "$@"
    ;;
  worker)
    shift 1
    exec "${SPARK_INSTALL_DIR}/bin/spark-class" "org.apache.spark.deploy.worker.Worker" "$@"
    ;;
  *)
    exec "$@"
    ;;
esac
