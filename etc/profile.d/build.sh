export RUSTFLAGS="-C target-cpu=native -g"
export RUST_LOG=info
export RUST_BACKTRACE=full
export FFI_BUILD_FROM_SOURCE=1
export FFI_USE_MULTICORE_SDR=1
export GOLOG_LOG_LEVEL=info
export FFI_USE_CUDA=1
export BELLMAN_CUDA_NVCC_ARGS="--fatbin --gpu-architecture=sm_75 --generate-code=arch=compute_75,code=sm_75"
export NEPTUNE_CUDA_NVCC_ARGS="--fatbin --gpu-architecture=sm_75 --generate-code=arch=compute_75,code=sm_75"
