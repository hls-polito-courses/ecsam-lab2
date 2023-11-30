# Command example: <command> GROUP=0 BOARD=0 [MODEL_OB=mobilenet_v1] [BATCH_SIZE=1 PRECISION=16]

ifndef GROUP
$(error ERROR! Please, provide your group number. Example: make <cmd> GROUP=0)
endif

ifndef BOARD
$(error ERROR! Please, provide your board number. Example: make <cmd> BOARD=0)
endif

export MODEL=trained_lenet5
export DEVICE=192.168.99.1${BOARD}
export MODEL_PATH=EESAM/mnist_jn/models_test
export ECSAM_PATH=EESAM/mnist_jn/build${GROUP}

ssh:
	./sshexpect.sh ${DEVICE} ''

sshy:
	./sshexpect.sh ${DEVICE} '-Y'

init_cuda:
	cd template_plugin && cmake . -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc

compile:
	cd template_plugin && make -j

scp_jn:
	./scpexpect.sh ipynb/models/${MODEL}.pb group1@${DEVICE}:~/${MODEL_PATH}/group${GROUP}.pb
	./sshexpect.sh ${DEVICE} "mkdir -p ~/${ECSAM_PATH}/plugin"
	./scpexpect.sh template_plugin/plugin/clipKernel.cu group1@${DEVICE}:~/${ECSAM_PATH}/plugin

compile_jn:
	./sshexpect.sh ${DEVICE} "cd ~/${ECSAM_PATH} && cmake . -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc && make -j"

run_jn_16:
	./sshexpect.sh ${DEVICE} "cd ~/${ECSAM_PATH}/.. && python3 mnist_jn.py -p 16 -g ${GROUP}"

run_jn_32:
	./sshexpect.sh ${DEVICE} "cd ~/${ECSAM_PATH}/.. && python3 mnist_jn.py -p 32 -g ${GROUP}"

scp_jpg:
	./scpexpect.sh group${GROUP}.jpg group1@${DEVICE}:~/EESAM/obj_detect/selfies
	
scp_inferred:
	./scpexpect.sh group1@${DEVICE}:~/EESAM/obj_detect/selfies_results/group${GROUP}_resized_inferred.jpg .

ifndef MODEL_OB
override MODEL_OB = mobilenet_v1
endif

run_selfies:
	./sshexpect.sh ${DEVICE} "cd EESAM/obj_detect && python3 detect_selfies.py selfies -m ${MODEL_OB}"

ifndef BATCH_SIZE
override BATCH_SIZE = 1
endif

ifndef PRECISION
override PRECISION = 16
endif

run_ob:
	./sshexpect.sh ${DEVICE} "cd EESAM/obj_detect && python3 voc_evaluation_test.py -f -p ${PRECISION} -b ${BATCH_SIZE} -m ${MODEL_OB} -voc /home/shared/VOC2007"
	
metrics:
	./sshexpect.sh ${DEVICE} "cd EESAM/obj_detect && cat metrics.log"

scp_metrics:
	./scpexpect.sh group1@${DEVICE}:~/EESAM/obj_detect/metrics.log .