#!/usr/bin/env bash
set -euo pipefail

# Directories to use
SRC_DIR="$(cd $(dirname "$0") && pwd)"
ENV_DIR="$(pwd)/venv"
NUMPROC=$(nproc)

# Specific commits to checkout
SBLU_COMMIT=65c6348
PRODY_VERSION=1.10.11

# Setup conda env
if [ ! -d "${ENV_DIR}" ]; then
    conda env create -f "${SRC_DIR}/conda-env.yml" --prefix "${ENV_DIR}"
fi

# Create conda environment in the current directory
set +u  # conda references PS1 variable that is not set in scripts
source activate "${ENV_DIR}"
set -u

# Setting env variables
set +u
export PKG_CONFIG_PATH="${ENV_DIR}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export PATH="${ENV_DIR}/bin:${ENV_DIR}/lib:${PATH}"
export LD_LIBRARY_PATH="${ENV_DIR}/lib:${LD_LIBRARY_PATH}"
set -u

#pip install pytorch-lightning

# for sequential parallelism
pip install https://github.com/PyTorchLightning/fairscale/archive/pl_1.2.0.zip

# Install se3 cnn kernels
pip install appdirs # for e3nn
pip install git+https://github.com/AMLab-Amsterdam/lie_learn.git@51b494fc42117575f982ce25977ba5df9682dd3a
pip install git+https://github.com/mariogeiger/se3cnn.git@546bc682887e1cb5e16b484c158c05f03377e4e9

# Install mol_grid
pip install git+https://bitbucket.org/ignatovmg/mol_grid.git@cd412ca294a7585cad62968e9f54f50542604ea4

# Install ProDy
pip install pyparsing
pip install prody==${PRODY_VERSION}

# Install ray tune
pip install ray tensorboard hyperopt
pip install ray[tune]

# Install sb-lab-utils
git clone https://bitbucket.org/bu-structure/sb-lab-utils.git
cd sb-lab-utils
git checkout ${SBLU_COMMIT}
pip install -r requirements/pipeline.txt
python setup.py install
cd ../
rm -rf sb-lab-utils
