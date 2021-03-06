#!/bin/bash

get_free_gpu () {
	if [ $2 -eq 1 ]
	then
		echo 'Sleeping'
	    sleep 1m
	fi
	while true
	do
		for (( gpu=0; gpu<$1; gpu++ ))
		do
			VAR1=$( nvidia-smi -i $gpu --query-gpu=pci.bus_id --format=csv,noheader )
			VAR2=$( nvidia-smi -i $gpu --query-compute-apps=gpu_bus_id --format=csv,noheader )
			if [ "$VAR1" != "$VAR2" ]
			then
				return $gpu
			fi
		done
		echo 'Waiting for free GPU.'
		sleep 1m
	done
}

TRAIN=0
MAX_EPOCHS=200
INFER=1
EPOCH=175
MBATCH_SIZE=10
SAMPLE_SIZE=1000
OUT_TYPE='y'
GAIN='mmse-lsa' # if OUT_TYPE is 'y'.
T_W=32
T_S=16
MIN_SNR=-10
MAX_SNR=20
SET_PATH='set'
DATA_PATH='data'
TEST_X_PATH='set/test_noisy_speech'
OUT_PATH='out'
MODEL_PATH='model'
WAIT=0
NUM_GPU=2

for EPOCH in {100..200..5}
do
get_free_gpu $NUM_GPU $WAIT
python3 deepxi.py --ver '3f' --train $TRAIN --max_epochs $MAX_EPOCHS --infer $INFER --epoch $EPOCH \
	--gpu $? --mbatch_size $MBATCH_SIZE --sample_size $SAMPLE_SIZE --set_path $SET_PATH --data_path $DATA_PATH \
	--T_w $T_W --T_s $T_S --min_snr $MIN_SNR --max_snr $MAX_SNR --test_x_path $TEST_X_PATH \
	--out_path $OUT_PATH --model_path $MODEL_PATH --out_type $OUT_TYPE --gain $GAIN
done