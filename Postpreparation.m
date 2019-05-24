% clc;
% clear all;
% close all;
fileID = fopen('/home/rishabh/hourglass-experiments-laptops/src/Data_Laptop.txt','a');
%image_dir = dir('/tmp/rishabh/syn_images_keypoints_cropped_bkg_overlaid/*.jpg');
%annotations_dir = dir('/home/rishabh/RenderForCNN_KM/data/syn_keypoint_annotations_cropped/*.txt');
output_directory = fullfile('/tmp', 'rishabh', 'new'); 
num = length(image_dir);
%num = 200000;
for i = 200001:num
    disp(i)
    fprintf(fileID,'%d /tmp/rishabh/new/%s/ ',i,image_dir(i).name);
    image_path = strcat('/tmp/rishabh/syn_images_keypoints_cropped_bkg_overlaid/',image_dir(i).name);
    image = imread(image_path);
    [row col depth] = size(image); 
    image = imresize(image, [64 64]);
%     dest_file = strcat('/tmp/rishabh/new/',image_dir(i).name);
%     imwrite(image,dest_file);
    annotations = strsplit(image_dir(i).name,'.');
    annotation_path = strcat('/home/rishabh/RenderForCNN_KM/data/syn_keypoint_annotations_cropped/',annotations(1),'.txt');
    data = importdata(annotation_path{1});
    %imshow(image),hold on,
    for j = 1:6
        x = (data(j,1)/col)*64;
        y = (data(j,2)/row)*64;
        %scatter(x,y,'filled');
        fprintf(fileID,'%f,%f,',x,y);
    end
    fprintf(fileID,' %d\n',0);
end