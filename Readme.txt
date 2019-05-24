This readme has steps to run RenderForCNN for synthesizing 2D images from 3D CAD models.

One IMP change : 
	In render_model_view_keypoints.py. Earlier tilt was not being taken care of,if you had non zero tilt in your viewpoint stastics,it would give erroneous results. Hence account for that
	Change this :
		X_cur = rotx(np.radians(elevation_deg)) * roty(np.radians(azimuth_deg)) * R_obj_cam * X_cur
	To :
		X_cur = rotz(np.radians(-1*theta_deg))*rotx(np.radians(elevation_deg))*roty(np.radians(azimuth_deg))* R_obj_cam* X_cur

1.) In global_variables.m specify the class and the paths. Run the file via MATLAB.

2.) Run 'run_sampling.m' via MATLAB with the class you want. This would lead to generation of the following folders in RenderForCNN/data : truncation_distribution, truncation_statistics, viewpoint_distribution, viewpoint_stastics. Delete the already present folder(s).

3.) Run 'python run_render_keypoints.py' in the RenderForCNN/render_pipeline directory. This would generate synthetic images without any truncation or background overlaying. Before that :
	- In file 'setup.py' set the class.
	- In global_variables.py :
		* set up the blender/matlab paths as necessary.
 		* set up the data paths for : PASCAL,SHAPE NET as well as the SUN dataset.
		* assign the variable ,'g_shape_synset_name_pairs',with ID and the class name, accrording to the class you want.
		* setup the ID in 'g_shapenet_car_custom_folder'
		* setup the path 'g_syn_images_keypoints_folder' where the synthesized images will be stored.
		* a file should be inside the RenderForCNN/data which contains the annotations of the CAD model.
	- In RenderFoCNN/render_pipeline/render_helper_keypoints.py :
		- view_num : max number of images per model to be generated. 
		- in the function 'load_car_views()' specify the file for the class. ( This will load data generated in STEP 2 )

4.) Run 'RenderForCNN/render_pipeline/crop_images_batch_keypoints.m' via MATLAB. This would crop the images based on the class statistics obtained using PASCAL dataset in STEP 2. Before that, in the file specify : 		
		- the class number and name.
		- the annotation source(obtained after running STEP 3)  and destination folders.

5.) Run 'RenderForCNN/render_pipeline/overlay_background_batch_keypoints.m' via MATLAB. This would render the cropped images on a background from SUN Dataset. Before that :
	- the class number and name.
	- the annotation source(obtained after running STEP 4) and destination folders.

==========
NOTE 1 : The file samle_viewpoints.m called from run_sampling.m can be modified to sample realistic angles for vehicles in for driving scenarios.
NOTE 2 : Run all the global files before running the code.
==========
	



