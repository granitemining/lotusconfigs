export RUSTFLAGS="-C target-cpu=native -g"
export RUST_LOG=info
export RUST_BACKTRACE=full
export FFI_BUILD_FROM_SOURCE=1
export FFI_USE_MULTICORE_SDR=1
export GOLOG_LOG_LEVEL=info

PATH=$PATH:~/.cargo/bin:/usr/local/go/bin:/fil/common/repos/lotusconfigs/bin
if [ -n "$PATH" ]; then
  old_PATH=$PATH:; PATH=
  while [ -n "$old_PATH" ]; do
    x=${old_PATH%%:*}       # the first remaining entry
    case $PATH: in
      *:"$x":*) ;;          # already there
      *) PATH=$PATH:$x;;    # not there yet
    esac
    old_PATH=${old_PATH#*:}
  done
  PATH=${PATH#:}
  unset old_PATH x
fi
