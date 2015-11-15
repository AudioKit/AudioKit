#! /bin/bash
jazzy --module AudioKit \
      --github_url https://github.com/audiokit/AudioKit \
      --author "Aurelius Prochazka" \
      --author_url http://audiokit.io/ \
      --source-directory ../AudioKit/ \
      --readme ../README.md \
      --min-acl internal \
      --categories ./bin/doc_categories_au.yaml \
      --swift-version 2.1

open docs/index.html
#       --exclude ../Examples/TestApp/TestApp/ViewController.swift \
