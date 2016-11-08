#!/usr/bin/env bash

set -ev

bundle install

cd test
rake
