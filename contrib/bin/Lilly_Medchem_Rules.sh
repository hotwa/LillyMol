#!/usr/bin/env bash

here=$(readlink -f $(dirname $0));

exec ruby ${here}/Lilly_Medchem_Rules.rb "$@"
