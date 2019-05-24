#!/usr/bin/python

'''
Prepare training data in the form of a text file that contains image path and 
the corresponding ground truth label
'''

import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(BASE_DIR)
sys.path.append(os.path.dirname(BASE_DIR))
from global_variables import *

import math
import numpy as np
import random


# Extracts label from path of rendered images
def path2label(path):
	# A filename has six parts separated by '_'
    parts = os.path.basename(path).split('_')
    # The third, fourth, and fifth parts correspond to azimuth, elevation, and tilt
    azimuth = int(parts[2][1:]) % 360
    elevation = int(parts[3][1:]) % 360
    tilt = int(parts[4][1:]) % 360
    return (azimuth, elevation, tilt)


# Converts azimuth elevation and tilt labels to a rotation matrix
def rotationMatrixFromLabels(azimuth, elevation, tilt):

	ca = math.cos(math.radians(azimuth))
	sa = math.sin(math.radians(azimuth))
	ce = math.cos(math.radians(elevation))
	se = math.sin(math.radians(elevation))
	ct = math.cos(math.radians(tilt))
	st = math.sin(math.radians(tilt))

	# The overall rotation matrix is computed as
	# 	R = rotz(tilt) * rotx(elevation) * rotz(azimuth)
	Rz_tilt = np.matrix([[ct, -st, 0], [st, ct, 0], [0, 0, 1]])
	Rx_elevation = np.matrix([[1, 0, 0], [0, ce, -se], [0, se, ce]])
	Rz_azimuth = np.matrix([[ca, 0, sa], [0, 1, 0], [-sa, 0, ca]])

	return np.matmul(Rz_tilt, np.matmul(Rx_elevation, Rz_azimuth))


# Main method
if __name__ == '__main__':

	for idx, sysnet in enumerate(g_shape_synsets):

		# Sysnet ID
		name = g_shape_synsets[idx]
		
		# Path to text file in which training data is to be stored
		train_image_label_file = os.path.join(g_syn_images_lmdb_folder, sysnet + '_train.txt')
		val_image_label_file = os.path.join(g_syn_images_lmdb_folder, sysnet + '_val.txt')
		test_image_label_file = os.path.join(g_syn_images_lmdb_folder, sysnet + '_test.txt')

		# Train, Val, Test splits
		train_ratio = 0.75
		val_ratio = 0.15

		# Label type ('classification' for azimuth, elevation, tilt class labels)
		# ('regression' for rotation matrix labels)
		label_type = 'regression'

		# Path to the image folder
		image_folder = os.path.join(g_syn_images_bkg_overlaid_folder, sysnet)
		all_md5s = os.listdir(image_folder)
		train_val_split = int(len(all_md5s) * train_ratio)
		val_test_split = int(len(all_md5s) * (train_ratio + val_ratio))
		train_md5s = all_md5s[0:train_val_split]
		val_md5s = all_md5s[train_val_split:val_test_split]
		test_md5s = all_md5s[val_test_split:]

		# Generate train, val, and test data
		for md5s_list, image_label_file in [(train_md5s, train_image_label_file), (val_md5s, val_image_label_file), (test_md5s, test_image_label_file)]:

			image_filenames = []
			for k, md5 in enumerate(md5s_list):
				if k % (1 + len(md5s_list)/20) == 0:
					print ('shape: %s, %d / %d: %s' % (sysnet, k, len(md5s_list), md5))
				shape_folder = os.path.join(image_folder, md5)
				shape_images = [os.path.join(shape_folder, x) for x in os.listdir(shape_folder)]
				image_filenames += shape_images
			image_filename_label_pairs = [(fpath, path2label(fpath)) for fpath in image_filenames]
			random.shuffle(image_filename_label_pairs)

			fout = open(image_label_file, 'w')
			print image_filename_label_pairs[0], len(image_filename_label_pairs)
			for metadata in image_filename_label_pairs:
				if label_type == 'classification':
					fout.write('%s %d %d %d\n' % (metadata[0], metadata[1][0], metadata[1][1], metadata[1][2]))
				elif label_type == 'regression':
					label = rotationMatrixFromLabels(metadata[1][0], metadata[1][1], metadata[1][2])
					fout.write('%s %f %f %f %f %f %f %f %f %f\n' % (metadata[0], label[0,0], label[0,1], label[0,2], label[1,0], label[1,1], label[1,2], label[2,0], label[2,1], label[2,2]))
			fout.close()
