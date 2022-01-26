#!/usr/bin/bash

set -e

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
OUT_DIR=~/vigor/bdds
REPORT=$SCRIPT_DIR/generate_bdds.report

rm -f $REPORT > /dev/null 2>&1
touch $REPORT
mkdir -p $OUT_DIR

function generate_for_nf {
    nf_name=$1

    echo "[$nf_name] Running symbex"
    cd $VIGOR_DIR/vigor/$nf_name
    make symbex >> $REPORT 2>&1

    echo "[$nf_name] Generating BDD"
    cd $KLEE_DIR
    ./build.sh >> $REPORT 2>&1
    ./build/bin/call-paths-to-bdd $VIGOR_DIR/vigor/$nf_name/klee-last/*call_path \
        -out $OUT_DIR/$nf_name.bdd -gv $OUT_DIR/$nf_name.gv >> $REPORT 2>&1
    
    echo "[$nf_name] Done"
}

generate_for_nf "vignop"
generate_for_nf "vigpol"
generate_for_nf "vigbridge-static"
generate_for_nf "vigbridge"
generate_for_nf "vigfw"
generate_for_nf "vignat"
generate_for_nf "viglb"
generate_for_nf "vighhh"
generate_for_nf "vigpsd"
generate_for_nf "vigcl"

rm -f $REPORT > /dev/null 2>&1
