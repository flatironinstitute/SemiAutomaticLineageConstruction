# register raw images
# register label images (from stardist and/or correction tool)
# and make maximum intensity projection video

# inputs
# raw image path and format
# label image path and format
# registration transforms (json) - first convert with mat2json.py
# output path (by default label path)


import numpy as np
import os
import math
from scipy.ndimage import affine_transform
from scipy.ndimage import zoom
import tifffile as tiff
import glob
import argparse
import json
import pyklb
import cv2
from GeometricInterpolation import InterpolateTubes

########################################################################################

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('-l', '--label_path', type=str,  default='.',
                        help='the path of the 3D label images')
    parser.add_argument('-i', '--image_path', type=str,  default='.',
                        help='the path of the 3D raw images')
    parser.add_argument('-t', '--transform_filename', type=str,  default='transforms.json',
                        help='the filename of the json transform file')
    parser.add_argument('-o', '--output_path', type=str,
                        help='the output path - for registered raw and label images')
    parser.add_argument('-s', '--start', type=int,  default=None,
                        help='start of sequence - integer')
    parser.add_argument('-e', '--end', type=int,  default=None,
                        help='end of sequence - integer')
    args = parser.parse_args()

label_path = args.label_path
print('label_path ', label_path)
if args.output_path is None:
    print('setting output path to label_path')
    out_path = os.path.dirname(label_path)
else:
    out_path = args.output_path

if not os.path.exists(out_path):
    os.mkdir(out_path)
print('out_path ',out_path)

image_path = args.image_path
start_frame = args.start
end_frame = args.end
transform_path = os.path.dirname(label_path)
transform_name = args.transform_filename

# read in registration transforms
embryo_path = transform_path
fid = open(os.path.join(embryo_path,transform_name),'r')
transforms = json.load(fid)

new_image_path = os.path.join(out_path,'registered_images')
if not os.path.exists(new_image_path):
    os.mkdir(new_image_path)
new_label_path = os.path.join(out_path,'registered_label_images')
if not os.path.exists(new_label_path):
    os.mkdir(new_label_path)
MIP_path = os.path.join(out_path,'MIP-Frames')
if not os.path.exists(MIP_path):
    os.mkdir(MIP_path)

bLabels = True # set to false if only want to register raw images
for iframe in range(start_frame,end_frame+1): #
    frame_str = '%05d' % iframe
    image_fullname = image_path % (iframe,iframe)
    print(image_fullname)
    suffix = image_fullname[-3:]
    if (suffix == 'klb'):
        img = pyklb.readfull(image_fullname)
    else:
        img = tiff.imread(image_fullname)
    d,h,w = img.shape
    if bLabels:
        # read label image - 100_masks_mi_0001.tif
        label_fullname = label_path % iframe
        # if doesn't exist - try
        lux_suffix_for_embryo_alternative = '.lux_SegmentationCorrected.tif';
        suffix_for_embryo_alternative = '.SegmentationCorrected.tif';
        if (os.path.exists(label_fullname)):
            label_img = tiff.imread(label_fullname)
        else:
            lux_part = label_fullname[-8:-4]
            print(lux_part)
            if (lux_part == '.lux'):
                label_fullname = label_fullname[:-8] + lux_suffix_for_embryo_alternative
            else:
                label_fullname = label_fullname[:-8] + lux_suffix_for_embryo_alternative
            label_img = tiff.imread(label_fullname)

        # before downsampling  by 4 -- label image is fully upsampled
        new_label_img = InterpolateTubes(label_img, 10)
        print(new_label_img.shape)
        print('number of labels ', len(np.unique(new_label_img)))

    print(img.shape)
    img = img >> 4
    img = img.astype(dtype=np.uint8)
    # down sample x/y by 4  -> each pixel is 0.832 apart
    # up sample z by 2.0/(0.832) -> each pixel is 0.832 apart
    dest_size = ( 2.0/0.832, .25, .25 )
    new_img = zoom(img, dest_size, order=3) # up to 5 - higher order spline interpolation
    print(new_img.shape)

    if bLabels:
        new_label_img = np.swapaxes(new_label_img,0,2)
    new_img = np.swapaxes(new_img,0,2)
    print(new_img.shape)
    w,h,d = new_img.shape

    # center at centroid
    # get centroids from registration file
    C1 = transforms['store_registration'][iframe-1]['Centroids1'] # frames are off by one because when
    # converted to json the list becomes zero indexed
    meanX = C1[0]
    meanY = C1[1]
    meanZ = C1[2]
    print('centroid ', meanX, meanY, meanZ)
    if (iframe == end_frame):
        # no change to original
        Rev_Rotation = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
        Rev_Offset = [0,0,0]
        reg_img = new_img
        if bLabels:
            reg_label_img = new_label_img
    else:
        # compute cumulative registration transform
        Cumulative_Rotation = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
        RevR1 = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1]])
        RevT1 = [0, 0, 0]
        for iframe_seq in range(iframe, end_frame):
            # get current mean
            C1 = transforms['store_registration'][iframe_seq - 1]['Centroids1']  # frames are off by one because when
            meanX = C1[0]
            meanY = C1[1]
            meanZ = C1[2]
            print('C1 ', meanX,meanY,meanZ)
            C2 = transforms['store_registration'][iframe_seq - 1]['Centroids2']  # frames are off by one because when
            meanX2a = C2[0]
            meanY2a = C2[1]
            meanZ2a = C2[2]
            print('C2 ',meanX2a,meanY2a,meanZ2a)
            C2 = transforms['store_registration'][iframe_seq]['Centroids1']  # frames are off by one because when
            meanX2b = C2[0]
            meanY2b = C2[1]
            meanZ2b = C2[2]
            print('C2 ',meanX2b,meanY2b,meanZ2b)
            Mean_Offset = np.array([meanX2b, meanY2b, meanZ2b])
            Rotation = transforms['store_registration'][iframe_seq - 1]['Rotation']
            Translation = transforms['store_registration'][iframe_seq - 1]['Translation'][0]  # this is 1x3
            Cumulative_Offset = np.matmul(Rotation, Mean_Offset + Translation)
            # needs to be reverse transform
            RevR2 = Rotation
            RevT2 = -Cumulative_Offset + [meanX, meanY, meanZ] #[meanX, meanY, meanZ] + DiffC

            # combine this with previous
            Rev_Rotation = np.matmul(RevR1, RevR2)
            Rev_Offset = np.matmul(RevR1, RevT2) + RevT1
            # update for next iteration
            RevR1 = Rev_Rotation
            RevT1 = Rev_Offset

        reg_img = affine_transform(new_img,Rev_Rotation,Rev_Offset,order=3) # higher order for higher order spline interpolation
        if bLabels:
            sf = 4 # label image is 4x bigger than raw image
            lab_Offset = [value * sf for value in Rev_Offset]
            reg_label_img = affine_transform(new_label_img, Rev_Rotation, lab_Offset, order = 0, mode = 'nearest')

    # if saving the image here - reverse x/z
    reg_img_swap = np.swapaxes(reg_img,0,2)
    if bLabels:
        reg_label_swap = np.swapaxes(reg_label_img,0,2)
        dest_scale = [0.25, 0.25, 0.25]
        reg_label_swap = zoom(reg_label_swap, dest_scale, order=0, mode='nearest')

    #reg_img_swap = np.ascontiguousarray(reg_img_swap)
    #pyklb.writefull(reg_img_swap,os.path.join(new_image_path,'image_reg_' + frame_str + '.klb'))
    tiff.imwrite(os.path.join(new_image_path,'image_reg_' + frame_str + '.tif'),reg_img_swap)
    if bLabels:
        #reg_label_swap = np.ascontiguousarray(reg_label_swap)
        #pyklb.writefull(reg_label_swap, os.path.join(new_label_path, 'label_reg_' + frame_str + '.klb'))
        tiff.imwrite(os.path.join(new_label_path, 'label_reg_' + frame_str + '.tif'), reg_label_swap)

    # now make max intensity projection image
    max_proj_img = np.max(reg_img, axis=2)
    cv2.imwrite(os.path.join(MIP_path,'MIP_'
                                      '' + frame_str + '.jpg'), max_proj_img)



