#!/bin/bash
for i in yaml/effects/*.yaml; do ./bin/generate_operation.rb $i; done
