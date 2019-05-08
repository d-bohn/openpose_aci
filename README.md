# openpose_aci
Code and workflow for building [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose)
in Docker Hub and modifying it with Singularity Hub for use with PSU
ACI HPC clusters.

## Quick Start
## Quick Start
`ssh` into the PSU ACI HPC with X11 flags.

```
ssh USERID@aci-b.aci.ics.psu.edu -X -Y
```

Start an interactive session using `qsub`. We need a lot of memory for the CPU version
of OpenPose

```
qsub -A open -I -X -l walltime=24:00:00 -l nodes=5:ppn=10 -l pmem=20gb
```

From ACI pull the OpenPose image and shell into it.

```
singularity pull -n openpose_aci.simg shub://d-bohn/openpose_aci

singularity exec -n openpose_aci.simg /bin/bash
```

Finally, once inside the image you can run the example utilizing the following
code:

```
cd /opt/openpose
mkdir data && mkdir data/poses

./build/examples/openpose/openpose.bin --video examples/media/video.avi --write_video ./data/result.avi --write_json ./data/poses --display 0
```

## Image Builds
The OpenPose docker image was built on docker hub.

The OpenPose singularity image was built using the docker image base and
converting it to a singularity image via singularity hub.

Setup for linking Github with Docker Hub and Singularity Hub can be found here:

  - [docker Hub](https://docs.docker.com/docker-hub/)
  - [Singularity Hub](https://github.com/singularityhub/singularityhub.github.io/wiki)

The `Singularity` file specifies creating a Singularity-compatible image
from the docker image, as well as adding access to folders within ACI,  specifically:
```
# ACI mappings so you can access your files.
mkdir -p /storage/home
mkdir -p /storage/work
mkdir -p /gpfs/group
mkdir -p /gpfs/scratch
mkdir -p /var/spool/torque
```

## Notes
  - The OpenFace docker image is large (> 3.7GB). It is built on Ubuntu 16.04.

  - The current image is built with only CPU support, but can easily be adapted to
  include GPU support when that is available (see first two `make` flags in `Dockerfile`)

  - The CPU version is SLOW. The example above takes several minutes to execute. Runs at between
  0.3 and 0.1 frames/second.
