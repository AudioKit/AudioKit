#!/bin/bash
for i in yaml/*.yaml; do ./bin/generate_operation.rb $i; done
