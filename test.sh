#!/bin/bash

TESTS="read_corpus log settings"

cd tests;
# Systematically test all programs
for t in $TESTS; do
    echo "Running test $t"
    ./$t
    if [[ $? == 0 ]]; then
        echo "Success..."
    else
        echo "Fail..."
    fi
done;

