#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os
import sys
import shutil
import random
import tempfile
import datetime
from functools import partial
from multiprocessing.dummy import Pool
from subprocess import call

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.dirname(BASE_DIR))
from global_variables import *


# Return a list of all car models (.obj files)
def load_car_shape_list():
    
    # return a list of (id, path to .obj file, numofviews, keypoint annotations) tuples
    # shape_file_list = os.listdir(os.path.join(g_shapenet_car_custom_folder))

    # view_num = g_syn_images_num_per_category / len(shape_file_list)

    # Read the 3D keypoint annotation file
    annotationFile = open(g_shapenet_car_keypoint_annotation_file, 'r').readlines()
    annotation = []
    shape_file_list = []
    for line in annotationFile:
        line = line.strip().split()
        shape_file_list.append(line[0])
        annotation.append([float(line[i+1]) for i in range(len(line) - 1)])
    i = 0;    
    view_num = 1500 # Number of images per model.
    shape_list = []
    for shape_file in shape_file_list:
        # splitString = shape_file.strip().split('_')
        # splitString = splitString[2].strip().split('.')
        # shape_id = int(splitString[0])
        # # Verify if the car with this id has keypoints annotated
        
        annot = annotation[i]
        i = i + 1    
         # -1, since the ids are 1-based indices
        # If all entries are zeros, then the car is not annotated. We do a 'bad' but heuristic 
        # implementation of this check. We only check if the sum of the array elements is 0.
        # Ideally, one must check if each individual element is zero. Because, if there happened to 
        # be a very symmetric car whose keypoints sum to zero, the condition would still hold
        if sum(annot) == 0:
            continue
        annot_string = ''
        for item in annot:
            annot_string += str(item) + ' '
        shape_list.append((shape_file, os.path.join(g_shapenet_car_custom_folder, shape_file,'model.obj'), view_num, annot_string))
    return shape_list


# Samples viewpoints for the car category
def load_car_views():
    # return shape_synset_view_params : GENERATED FROM /render_pipeline/kde/run_sampling.m
    if not os.path.exists(os.path.join(g_data_folder, g_view_distribution_folder, 'car.txt')): 
        print('Failed to read view distribution files from %s' % 
              os.path.join(g_data_folder, g_view_distribution_folder, 'car.txt')) 
        exit()
    view_params = open(os.path.join(g_data_folder, g_view_distribution_folder, 'car.txt')).readlines()
    view_params = [[float(x) for x in line.strip().split(' ')] for line in view_params]
    return view_params


# Render the car models from different views, with keypoint annotations
def render_car_views_keypoints(shape_list, view_params):
    
    # Create a temporary directory
    tmp_dirname = tempfile.mkdtemp(dir=g_data_folder, prefix='tmp_view_keypoints')
    if not os.path.exists(tmp_dirname):
        os.mkdir(tmp_dirname)

    print('Generating rendering commands...')
    commands = []
    for shape_file, shape_file_path, view_num, keypoint_annotation in shape_list:
        # write tmp view file
        tmp = tempfile.NamedTemporaryFile(dir=tmp_dirname, delete=False)
        for i in range(view_num): 
            # parmaId = i; For exact the view_num imags per model.
            paramId = random.randint(0, len(view_params)-1)
            tmp_string = '%f %f %f %f\n' % (view_params[paramId][0], view_params[paramId][1], view_params[paramId][2], max(0.01,view_params[paramId][3]))
            tmp.write(tmp_string)
        tmp.close()

        # Display or not display the output.
        command = '%s %s --background --python %s -- %s %s %s %s %s %s > /dev/null 2>&1' % (g_blender_executable_path, g_blank_blend_file_path, os.path.join(BASE_DIR, 'render_model_views_keypoints.py'), shape_file_path, shape_file, tmp.name, os.path.join(g_syn_images_keypoints_folder), os.path.join(g_syn_annotations_folder), keypoint_annotation)
        #command = '%s %s --background --python %s -- %s %s %s %s %s %s ' % (g_blender_executable_path, g_blank_blend_file_path, os.path.join(BASE_DIR, 'render_model_views_keypoints.py'), shape_file_path, shape_file, tmp.name, os.path.join(g_syn_images_keypoints_folder), os.path.join(g_syn_annotations_folder), keypoint_annotation)
        commands.append(command)
    print('done (%d commands)!'%(len(commands)))
    # print commands[0]
   

    print('Rendering, it takes long time...')
    report_step = 10

    if not os.path.exists(os.path.join(g_syn_images_keypoints_folder)):
        os.mkdir(os.path.join(g_syn_images_keypoints_folder))


    pool = Pool(g_syn_rendering_thread_num)
    for idx, return_code in enumerate(pool.imap(partial(call, shell=True), commands)):
        if idx % report_step == 0:
            print('[%s] Rendering command %d of %d' % (datetime.datetime.now().time(), idx, len(shape_list)))
        if return_code != 0:
            print('Rendering command %d of %d (\"%s\") failed' % (idx, len(shape_list), commands[idx]))
    shutil.rmtree(tmp_dirname) 



