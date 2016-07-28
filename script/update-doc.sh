#!/bin/bash

git submodule update --init --recursive
bundle install
bundle exec jazzy 
mv docs/* .

