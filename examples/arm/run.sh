#!/usr/bin/env bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

set -eu

if [[ "${1:-'.'}" == "-h" || "${#}" -gt 2 ]]; then
    echo "Usage: $(basename $0) [path-to-a-scratch-dir] [buck2 binary]"
    echo "Supplied args: $*"
    exit 1
fi

########
### Hardcoded constants
########
script_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Ethos-u
root_dir=${1:-"${script_dir}/ethos-u-scratch"}
root_dir=$(realpath ${root_dir})
buck2=${2:-"/tmp/buck2"}
ethos_u_root_dir="$(cd ${root_dir}/ethos-u && pwd)"
ethos_u_build_dir=${ethos_u_root_dir}/core_platform/build
setup_path_script=${root_dir}/setup_path.sh

# Executorch
et_root_dir=$(cd ${script_dir}/../.. && pwd)
et_build_dir=${root_dir}/executorch-cmake-out

fvp_model=FVP_Corstone_SSE-300_Ethos-U55
toolchain_cmake=${script_dir}/ethos-u-setup/arm-none-eabi-gcc.cmake
_setup_msg="please refer to ${script_dir}/ethos-u-setup/setup.sh to properly install necessary tools."


# Generate the PTE file
function generate_pte_file() {
    cd $et_root_dir
    python3 -m examples.portable.scripts.export --model_name="softmax"
    local pte_file
    pte_file="$(realpath ./softmax.pte)"
    [[ -f ${pte_file} ]] || { echo "Failed to generate a pte file - ${pte_file}"; exit 1; }
    echo "${pte_file}"
}

# Generate the ethos delegate PTE file
function generate_ethos_pte_file() {
    cd $et_root_dir
    python3 examples/arm/arm_ethosu_minimal.py &> /dev/null
    cd ./ethosout/simple_add/torch/
    local pte_file=$(realpath ./delegated.pte)
    [[ -f ${pte_file} ]] || { echo "Failed to generate a pte file - ${pte_file}"; exit 1; }
    echo "${pte_file}"
}

# build ExecuTorch Libraries
function build_executorch() {
    [[ -d "${et_build_dir}" ]] \
        && echo "[${FUNCNAME[0]}] Warn: using already existing build-dir for executorch: ${et_build_dir}!!"
    mkdir -p "${et_build_dir}"

    cd "${et_build_dir}"
    cmake                                                 \
        -DBUCK2=${buck2}                                  \
        -DEXECUTORCH_BUILD_XNNPACK=OFF                    \
        -DEXECUTORCH_BUILD_GFLAGS=OFF                     \
        -DEXECUTORCH_BUILD_EXECUTOR_RUNNER=OFF            \
        -DEXECUTORCH_BUILD_HOST_TARGETS=OFF               \
        -DEXECUTORCH_BUILD_SDK=OFF                        \
        -DEXECUTORCH_BUILD_ARM_BAREMETAL=ON               \
        -DCMAKE_BUILD_TYPE=Release                        \
        -DEXECUTORCH_ENABLE_LOGGING=ON                    \
        -DEXECUTORCH_SELECT_OPS_LIST="aten::_softmax.out" \
        -DFLATC_EXECUTABLE="$(which flatc)"               \
        -DCMAKE_TOOLCHAIN_FILE="${toolchain_cmake}"       \
        "${et_root_dir}"

    echo "[${FUNCNAME[0]}] Configured CMAKE"

    n=$(nproc)
    cmake --build . -- -j"$((n - 5))"
    echo "[${FUNCNAME[0]}] Generated static libraries for ExecuTorch:"
    find . -name "*.a" -exec ls -al {} \;
}

# build Arm Baremetal executor_runner
function build_executorch_runner() {
    echo "[${FUNCNAME[0]}] Generating ExecuTorch libraries"
    [[ $# -ne 1 ]] && { echo "[${FUNCNAME[0]}]" "Expecting a single pte file as argument got, $*"; exit 1; }
    local pte=${1}
    cd "${ethos_u_root_dir}"/core_platform
    cmake                                         \
        -DCMAKE_TOOLCHAIN_FILE=${toolchain_cmake} \
        -B build targets/corstone-300             \
        -DET_DIR_PATH:PATH=${et_root_dir}         \
        -DET_BUILD_DIR_PATH:PATH=${et_build_dir}  \
        -DET_PTE_FILE_PATH:PATH="${pte}"          \
        -DPYTHON_EXECUTABLE=$(which python3)
    echo "[${FUNCNAME[0]}] Configured CMAKE"

    n=$(nproc)
    cmake --build build -- -j"$((n - 5))" executor_runner
    echo "[${FUNCNAME[0]}] Generated baremetal elf file:"
    find . -name "executor_runner.elf"
}

# Execute the executor_runner on FVP Simulator
function run_fvp() {
    [[ $# -ne 1 ]] && { echo "[${FUNCNAME[0]}]" "Expexted elf binary name, got $*"; exit 1; }
    local elf_name=${1}
    elf=$(find ${ethos_u_build_dir} -name "${elf_name}")
    [[ ! -f $elf ]] && { echo "[${FUNCNAME[0]}]: Unable to find executor_runner elf: ${elf}"; exit 1; }
    FVP_Corstone_SSE-300_Ethos-U55                          \
        -C ethosu.num_macs=128                              \
        -C mps3_board.visualisation.disable-visualisation=1 \
        -C mps3_board.telnetterminal0.start_telnet=0        \
        -C mps3_board.uart0.out_file='-'                    \
        -a "${elf}"                                         \
        --timelimit 5 || true # seconds
    echo "[${FUNCNAME[0]} Simulation complete, $?"
}

#######
### Main
#######
# Source the tools
# This should be prepared by the setup.sh
[[ -f ${setup_path_script} ]] \
    || { echo "Missing ${setup_path_script}. ${_setup_msg}"; exit 1; }
source ${root_dir}/setup_path.sh

# basic checks before we get started
hash ${fvp_model} \
    || { echo "Could not find ${fvp_model} on PATH, ${_setup_msg}"; exit 1; }

hash arm-none-eabi-gcc \
    || { echo "Could not find arm baremetal toolchain on PATH, ${_setup_msg}"; exit 1; }

[[ -f ${toolchain_cmake} ]] \
    || { echo "Could not find ${toolchain_cmake} file, ${_setup_msg}"; exit 1; }

[[ -f ${et_root_dir}/CMakeLists.txt ]] \
    || { echo "Executorch repo doesn't contain CMakeLists.txt file at root level"; exit 1; }

type ${buck2} 2>&1 > /dev/null \
    || { echo "Need a functioning buck2. Got ${buck2}."; exit 1; }

# build executorch libraries
build_executorch

# generate a .pte file - in this case a non-delegated one
pte=$(generate_pte_file)
# build and run the runner with a non-delegated .pte
build_executorch_runner "${pte}"
run_fvp executor_runner.elf

# generate a pte with an ArmBackend delegate
pte_delegate=$(generate_ethos_pte_file)
# build and run the same app with a delegated .pte
build_executorch_runner "${pte_delegate}"
run_fvp executor_runner.elf

exit 0