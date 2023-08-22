#!/bin/bash
set -x
num_threads="${NUM_THREADS:=16}"
prep_threads="${PREP_THREADS:=16}"
block_size="${BLOCK_SIZE:=4k}"
test_mode="${TEST_MODE:=rndrw}"
rw_ratio="${RW_RATIO:=4}"
run_time="${RUN_TIME:=30}"
data_size="${DATA_SIZE:=4g}"
file_num="${FILE_NUM:=128}"
extra_flags="${EXTRA_FLAGS:=direct}"
end_sleep="${END_SLEEP:=0}"
io_mode="${IO_MODE:=async}"
fsync_freq="${FSYNC_FREQ:=0}"

echo "Currently mounted filesystems for Random READ/WRITE test"
#df | grep 'data'
echo "Changing working directory to /tmp/data"
#cd /tmp/data
echo "Current working directory for control before execution"
pwd
set -x
echo sysbench --threads=${prep_threads} --test=fileio --file-num=${file_num} --file-total-size=${data_size} --file-test-mode=${test_mode} --file-block-size=${block_size}  --file-io-mode=${io_mode} --file-fsync-freq=${fsync_freq} prepare
set -x
#pwd >/tmp/trace.txt;ls >>/tmp/trace.txt
set -x
echo sysbench --threads=${num_threads} --test=fileio --file-num=${file_num} --file-total-size=${data_size} --file-test-mode=${test_mode} --file-block-size=${block_size} --file-extra-flags=${extra_flags} --time=${run_time} --file-rw-ratio=${rw_ratio} --file-io-mode=${io_mode} --file-fsync-freq=${fsync_freq} run
echo sysbench --threads=${prep_threads} --test=fileio --file-num=${file_num} --file-total-size=${data_size} --file-test-mode=${test_mode} --file-block-size=${block_size} --file-io-mode=${io_mode} --file-fsync-freq=${fsync_freq} cleanup
set +x
echo "Changing working directory to $HOME"
#cd ~
echo "Sleeping for ${end_sleep} seconds"
sleep ${end_sleep}
