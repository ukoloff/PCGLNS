#!/bin/bash
export JULIA_NUM_THREADS=$(nproc --all)
julia --check-bounds=no runPCGLNS.jl "$@"