#!/bin/bash
echo "Currently mounted filesystems for Random READ/WRITE test"
df | grep 'data'
echo "Changing working directory to /tmp/data"
cd /tmp/data
echo "Current working directory for control before execution"
pwd
set -x
sysbench --threads=64 --test=fileio --file-total-size=100g --file-test-mode=rndrd --file-block-size=4k  --file-io-mode=async --file-fsync-freq=0 prepare
set +x
pwd >/tmp/trace.txt;ls >>/tmp/trace.txt
set -x
sysbench --threads=64 --test=fileio --file-total-size=100g --file-test-mode=rndrd --file-block-size=4k --file-extra-flags=direct --file-fsync-freq=0 --time=600 --file-rw-ratio=4 --file-io-mode=async --file-fsync-freq=0 run
sysbench --threads=64 --test=fileio --file-total-size=100g --file-test-mode=rndrd --file-block-size=4k --file-io-mode=async --file-fsync-freq=0 cleanup
set +x
echo "Changing working directory to $HOME"
cd ~
