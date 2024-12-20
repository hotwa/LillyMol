FROM mambaorg/micromamba:cuda12.4.1-ubuntu22.04
ARG ROOT_PASSWD="micromamba"
ENV ROOT_PASSWD=${ROOT_PASSWD}

USER root
RUN <<EOT
#!/bin/bash
apt update
apt install vim git sudo bash-completion wget curl htop jq bzip2 npm unzip libz-dev libgomp1 libblas-dev liblapack-dev libzmq3-dev -y
echo "mambauser ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
echo "mambauser:${ROOT_PASSWD}" | chpasswd
EOT

USER mambauser
ENV LILLYMOL_HOME=/home/mambauser/LillyMol \
    BUILD_DIR=Linux \
    BUILD_BDB=1 \
    BUILD_PYTHON=1
RUN <<EOT
#!/bin/bash
echo "alias conda=micromamba" >> /home/mambauser/.bashrc
echo "alias mamba=micromamba" >> /home/mambauser/.bashrc
micromamba create -n lillymol python=3.10 pybind11 absl-py protobuf pandas scipy -y
echo "mamba activate lillymol" >> /home/mambauser/.bashrc
git clone https://github.com/IanAWatson/LillyMol /home/mambauser/LillyMol
EOT

WORKDIR /home/mambauser/LillyMol
RUN <<EOT
#!/bin/bash
npm install -g @bazel/bazelisk@7.0
cd src
bash ./build_third_party.sh
python update_python_in_workspace.py /home/mambauser/LillyMol/src/WORKSPACE
bazelisk -h
make all
EOT

# /home/mambauser/LillyMol/src/Molecule_Lib/linear_fingerprint_test.cc
# line 373 EXPECT_EQ(_sfc.nbits(), 5l);