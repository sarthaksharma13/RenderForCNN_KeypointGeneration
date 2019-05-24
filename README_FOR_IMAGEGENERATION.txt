The original Render For CNN code has been modified only for the sole purpose of generating millions of images as required for keypoint network training.

***RUN run_sampling.m : with the class you want.
*** One very critical change was also made in render_model_view_keypoints.py. Earlier tilt was not being taken care of,if you had non zero tilt in your viewpoint stastics,it would give erroneous results. Hence account for that
	#X_cur = rotx(np.radians(elevation_deg)) * roty(np.radians(azimuth_deg)) * R_obj_cam * X_cur
        X_cur = rotz(np.radians(-1*theta_deg))*rotx(np.radians(elevation_deg))*roty(np.radians(azimuth_deg))* R_obj_cam* X_cur



STEP 1 : run : python 'run_render_keypoints.py' in the 'render_pipeline' directory. This would generate synthetic images without any truncation or background overlaying. Before that :

######################################## CHANGES TO DO ########################################################

	1. in file setup.py : 
		- the class was solelely set to the 'car' class which we are interested in.

	2. in global_variable.m : 
		- again specify the class we are interested in.

	3. in global_variable.py : 
		- set up the blender/matlab paths as necessary.
 		- set up the data paths for : PASCAL,SHAPE NET as well as the SUN dataset.
		- assign the variable ,'g_shape_synset_name_pairs',with ID and the class name, accrording to the class you want.
		- setup the ID in 'g_shapenet_car_custom_folder
		- setup the path 'g_syn_images_keypoints_folder' where the millions of synthesized images will be stored.
		- a file should be inside the RenderForCNN/data/ which contains the annotations of the CAD model.

	4. in render_pipeline/run_render_keypoints.py : 
		- no change.
	
	5. in render_pipeline/render_helper_keypoints.py :
		- view_num : number of images per model to be generated. 
		- in the function 'load_car_views()' specify the camera parameter(explained below).

	6. There should be a folder called '/data/view_distribution' which contains the parameters of the camera as you want while generating the synthetic images.Each row entry in that file has four columns : az,elev,tilt,dist_frm_car. There should also '/data/view_statistics' (empty). This file would appear automatically after running 'render_pipeline/kde/run_sampling.m . You need to specify the class too in it. It is explained in STEP 2,part 1





STEP 2 : run : python 'render_pipeline/crop_images_batch_keypoints.m' in the 'render_pipeline' directory. This would crop the images based on the class statistics obtained using PASCAL dataset. Before that : 
######################################## CHANGES TO DO ########################################################

	1. run 'render_pipeline/run_sampling.m' : 
		- specify the class you are interested in. For that class it would automatically generate a mat file in the folder 'data/truncation_stastics' with the name class_truncation_stats.m
		-this function in turns calls 'get_voc12train_view_stats' and 'get_voc12train_truncation_stats' which in turn saves text files in 'data/view_distribution' and 'data/truncation distribution'. The former is used as camera parameters for generation of synthetic images while the latter for truncation code.

	2. in crop_images_batch_keypoints.m : 
		- specify the class number and name.
		- specify the annotation source and destination folders.




STEP 3 : run : python 'render_pipeline/overlay_background_batch_keypoints.m' in the 'render_pipeline' directory. This would render the cropped images on a background from SUN Dataset
######################################## CHANGES TO DO ########################################################

	1. run 'render_pipeline/run_sampling.m' : 
		- must be done before STEP 1 and STEP 2.	
	2. in crop_images_batch_keypoints.m : 
		- specify the class number and name.
		- specify the annotation source and destination folders.
		


********************************************************************************
ALSO THE FILE SAMPLE_VIEWPOINTS.M CALLED FROM RUN_SAMPLING.M was modified to sample realistic angles for cars,which somehow their code was not taking care of.




