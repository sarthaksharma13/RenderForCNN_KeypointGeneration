#!/usr/bin/python3
# -*- coding: utf-8 -*-
'''
RENDER_ALL_SHAPES
@brief:
    render shapes and keypoints for cars
'''

import os
import sys
import socket

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(BASE_DIR)
sys.path.append(os.path.dirname(BASE_DIR))
from global_variables import *
from render_helper_keypoints import *

if __name__ == '__main__':

    for idx in g_hostname_synset_idx_map[socket.gethostname()]:
        synset = g_shape_synsets[idx]
        print('%d: %s, %s\n' % (idx, synset, g_shape_names[idx]))
        shape_list = load_car_shape_list()
        view_params = load_car_views()
        render_car_views_keypoints(shape_list, view_params)
