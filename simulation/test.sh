#!/bin/bash

rm *.wlf
rm transcript


if [ ! -d "libs" ]; then
    mkdir libs
else
    rm -rf libs
     mkdir libs
fi

vlib libs/work
vmap work libs/work

vlog -f ./svfiles.f
vsim -lib work -t 1ps work.axi_tb -do run.do




