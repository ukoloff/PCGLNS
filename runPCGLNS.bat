set JULIA_NUM_THREADS=%NUMBER_OF_PROCESSORS%
julia --check-bounds=no runPCGLNS.jl %*