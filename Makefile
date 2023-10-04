export MODEL=trained_lenet5

ifndef GROUP
$(error ERROR! Please, provide your group number. Example: make GROUP=0)
endif

ifndef BOARD_NUMBER
$(error ERROR! Please, provide your board number. Example: make BOARD_NUMBER=0)
endif

scp_jn:
	scp ipynb/models/${MODEL}.pb group1@192.168.99.1${BOARD_NUMBER}:~/EESAM/mnist_jn/models_test/group${GROUP}.pb