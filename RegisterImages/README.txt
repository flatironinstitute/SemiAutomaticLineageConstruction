
MakeRegisteredImages

MakeRegisteredImages can be used to transform a sequence of raw and label images
into a sequence of registered images using the transform output from the matlab
code (see parent directory)

Dependencies: numpy, scipy, tifffile, glob, os, argparse, json, pyklb, cv2

Arguments:
    -l path and name format for label images (klb or tif) - if file not found will look for corrected version
    -i path and name format for raw images (klb)
    -o path of for output - but if not found will use the path to the label images
    -t name of transform file - needs to be json (see matlab code ConvertTransformsToJson.m to convert .mat to .json)
    -s start frame
    -e end frame

An example is given in the run_MakeRegisteredImages.sh file