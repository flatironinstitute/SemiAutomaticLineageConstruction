#!/bin/bash
#SBATCH --nodes=1
#sbatch -p ccb run_MakeRegisteredImages.sh
#SBATCH --ntasks-per-node=1
#SBATCH -t 7-00:00            # wall time (D-HH:MM)
#SBATCH --output=logs/log_MakeRegisteredImages.out

python3 MakeRegisteredImages.py -t transforms1_302.json -l /mnt/ceph/users/lbrown/Labels3DMouse/TestSets/EmbryoStats/211106_st5/Stardist3D_klbOut_Cam_Long_%05d.lux.tif -i /mnt/ceph/users/akohrman/for_inference/211106_all/stack_5_channel_2_obj_left/out/folder_Cam_Long_%05d.lux/klbOut_Cam_Long_%05d.lux.klb -s 1 -e 3
