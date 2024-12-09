#!/bin/bash
set -x
ruby_script="${0%%.sh}.rb"
exec ruby ${ruby_script} "$@"
