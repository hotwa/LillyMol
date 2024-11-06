#!/bin/bash
here=$(dirname $0)
export PATH=$(readlink -e $here):$PATH
exec ruby ${here}/make_descriptors.rb "$@"
