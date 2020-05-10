#!/bin/bash
export JULIA_NUM_THREADS=$(nproc)
julia --check-bounds=no runPCGLNS.jl "$@"