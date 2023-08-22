# SYSBENCH Container Image

## Why

The idea behind this project was to setup a quick benchmarking tool not using the FIO standard.
It was also to make available a base that could be customized by others to support leveraging
the other sysbench testing modes for CPU, RAM and otehr things `sysbench` supports.

Anotehr goal for the project was to easily determine if a `rook-ceph` of `Red Hat OpenShift Data Foundation`
environment could produce the desired throughout or bandwidth after deployment with parameters
that could easily stress the storage backend.

## Container Images

Two versions of the container image are available from my personal Quay repository:

. quay.io/vcppds7878/sysbench:original  Initial container image with only preset scripts. **DEPRECATED**
. quay.io/vcppds7878/sysbench:variable  Latest container image with both preset scripts and generic script

Note that the `variable` tag version uses CentOS Stream as a base and provides better security.

## Variable version

The file `/tmp/file-generic.sh` has been preloaded into the container image to provide
you with the ability to pass prep and run time parameters easily.

```
      containers:
      - name: {the_name_for_your_container}
        image: quay.io/vcppds7878/sysbench:bench64
        command: ["sh"]
        args:
          - '-c'
          - '/tmp/file-random-fio-generic.sh'
        env:
          - name: {VARIABLE_NAME}
            value: "{DESIRED_VALUE}"
```

The followign variables can be leveraged.

- NUM_THREADS:=16       Number of threads used during the run phase
- PREP_THREADS:=16      Number of threads for teh prepartion and cleanup phase
- BLOCK_SIZE:=4k        Block size for sysbench
- TEST_MODE:=rndrw      Test type. Values are rndwr, rndrd, rndrw, seqwr, seqrewr, seqrd
- RW_RATIO:=4           Define the read/write ratio. 4 is 80/20
- RUN_TIME:=30          Run time in seconds
- DATA_SIZE:=4g         Size of the dataset to use
- FILE_NUM:=128         Number of files to create. Defaults to sysbench default
- EXTRA_FLAGS:=direct   Extra flags to pass for IO
- END_SLEEP:=0          Sleep time at the end to prevent STS restart to collect statistics
- IO_MODE:=async        What mode to use. Default to libaio
- FSYNC_FREQ:=0         How often to force fsync
 
The default parameters chosen were designed to mimic FIO behavior for easy comparison.

The file `sysbench-generic-template.yaml` is a template to consume this built-in script.


## Fixed version

The following files have been preloaded into the container image for quick runs with preset value
in terms of dataset size, numebr of files, io size.

- file-random-read-4k.sh
- file-random-read-4m.sh
- file-random-read-fio-4k.sh
- file-random-readwrite-4k.sh
- file-random-readwrite-4m.sh
- file-random-readwrite-fio-4k.sh
- file-random-write-4k.sh
- file-random-write-4m.sh
- file-random-write-fio-4k.sh
- file-sequential-read-1g.sh
- file-sequential-read-4m.sh
- file-sequential-readwrite-1g.sh
- file-sequential-readwrite-4m.sh
- file-sequential-write-1g.sh
- file-sequential-write-4m.sh

To use the preloaded files configure your container to call for the desired script test file.

```
      containers:
      - name: {the_name_for_your_container}
        image: quay.io/vcppds7878/sysbench:bench64
        command: ["sh"]
        args:
          - '-c'
          - '/tmp/{file_name_from_the_above_list}'
```

This repo contains a `yaml` file for each preset version for easy consumption.

- sysbench-rwo-idle.yaml
- sysbench-rwo-rread-4k.yaml
- sysbench-rwo-rread-4m.yaml
- sysbench-rwo-rreadwrite-4k.yaml
- sysbench-rwo-rreadwrite-4m.yaml
- sysbench-rwo-rwrite-4k.yaml
- sysbench-rwo-rwrite-4m.yaml
- sysbench-rwo-sread-1g.yaml
- sysbench-rwo-sread-4m.yaml
- sysbench-rwo-sreadwrite-1g.yaml
- sysbench-rwo-sreadwrite-4m.yaml
- sysbench-rwo-swrite-1g.yaml
- sysbench-rwo-swrite-4m.yaml
- sysbench-rwx-idle.yaml
- sysbench-rwx-rread-4k.yaml
- sysbench-rwx-rread-4m.yaml
- sysbench-rwx-rreadwrite-4k.yaml
- sysbench-rwx-rreadwrite-4m.yaml
- sysbench-rwx-rwrite-4k.yaml
- sysbench-rwx-rwrite-4m.yaml
- sysbench-rwx-sread-1g.yaml
- sysbench-rwx-sread-4m.yaml
- sysbench-rwx-sreadwrite-1g.yaml
- sysbench-rwx-sreadwrite-4m.yaml
- sysbench-rwx-swrite-1g.yaml
- sysbench-rwx-swrite-4m.yaml
- sysbench-sts-variable.yaml

NOTE: Feel free to change the storage class in each `yaml` file to match your Kubernetes or
OpenShift configuration.

## Stateful Set configuration

This repo contains file `sysbench-sts-variable.yaml` for starting the test via a stateful set in a Kubernetes
or Red Hat OpenShift environment.

When running with a stateful set you can collect the statistics of all the pods after they
reach a completeion status using file collect-sysbench-sts.sh

