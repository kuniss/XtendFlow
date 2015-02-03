#!/bin/bash
set -ev
if [ -n "${TRAVIS_TAG}" ]; then
  cd FlowDesignInXtend-ActiveAnnotations
  ./gradlew release "-PreleaseVersion=${TRAVIS_TAG}"
fi
