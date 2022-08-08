import glob
from PIL import Image
import os

# make animated gif
frame_folder = '/mnt/ceph/users/lbrown/Labels3DMouse/GTSets/FSequenceData/SeqF32_40masks/MIP-Frames/'
embryo_base = 'MIP_'
frames = []
start = 1
end = 137
for iframe in range(start,end+1):
    range_str = str(start) + '_' + str(end)
    frame_str = '%05d' % iframe
    embryo_file = embryo_base + frame_str + '.jpg'
    fname = os.path.join(frame_folder,embryo_file)
    print(fname)
    img = Image.open(fname)
    frames.append (img)

frame_one = frames[0]
frame_one.save(os.path.join(frame_folder,"RegisteredRawMIP' + range_str + '.gif"), format="GIF", append_images=frames,
               save_all=True, duration=300) # loop=1)  # ~2 sec/frame ?