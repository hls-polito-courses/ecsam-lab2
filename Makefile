ifndef GROUP
$(error ERROR! Please, provide your group number. Example: make GROUP=0)
endif

ifndef BOARD_NUMBER
$(error ERROR! Please, provide your board number. Example: make BOARD_NUMBER=0)
endif

export MODEL=trained_lenet5
export DEVICE=192.168.99.1${BOARD_NUMBER}
export MODEL_PATH=EESAM/mnist_jn/models_test
export ECSAM_PATH=EESAM/mnist_jn/build${GROUP}

init_cuda:
	cd template_plugin && cmake . -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc

compile:
	cd template_plugin && make -j

scp_jn:
	scp ipynb/models/${MODEL}.pb group1@${DEVICE}:~/${MODEL_PATH}/group${GROUP}.pb
	ssh group1@${DEVICE} "mkdir -p ~/${ECSAM_PATH}/plugin"
	scp template_plugin/plugin/clipKernel.cu group1@${DEVICE}:~/${ECSAM_PATH}/plugin/​

compile_jn:
	ssh group1@${DEVICE} "cd ~/${ECSAM_PATH} && cmake . -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc && make -j"

run_jn_16:
	ssh group1@${DEVICE} "cd ~/${ECSAM_PATH}/.. && python3 mnist_jn.py -p 16 -g ${GROUP}"

run_jn_32:
	ssh group1@${DEVICE} "cd ~/${ECSAM_PATH}/.. && python3 mnist_jn.py -p 32 -g ${GROUP}"
