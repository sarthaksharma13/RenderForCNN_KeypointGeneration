%% Script to save all the images with keypoints overlayed. For verification purpose only.
% Sarthak Sharma.
clc;close all;clear all;

%% Save the normal images(without any cropping or background overlaying);
%specify the image directory.
imgDir = dir('/tmp/sarthaksharma/syn_images_keypoints/*.png');
saveDir = '/tmp/sarthaksharma/save_syn_images_keypoints';

if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

for imgNum = 1:size(imgDir,1)
    
    img = imread(['/tmp/sarthaksharma/syn_images_keypoints/' imgDir(imgNum).name]);
    annotations = importdata(['../data/syn_keypoint_annotations/',imgDir(imgNum).name(1:end-4),'.txt']);
    f=figure;imshow(img);hold on;scatter(annotations(:,1),annotations(:,2),'r','Filled');
    saveas(f,['/tmp/sarthaksharma/save_syn_images_keypoints/' ,imgDir(imgNum).name(1:end-4) ,'.png']);close all;
    
end

%% Save the cropped images;

%specify the image directory.
imgDir = dir('/tmp/sarthaksharma/syn_images_keypoints_cropped/*.png');
saveDir = '/tmp/sarthaksharma/save_syn_images_keypoints_cropped';

if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

for imgNum = 1:size(imgDir,1)
    
    
    img = imread(['/tmp/sarthaksharma/syn_images_keypoints_cropped/' ,imgDir(imgNum).name]);
    annotationsCropped =  importdata(['../data/syn_keypoint_annotations_cropped/',imgDir(imgNum).name(1:end-4),'.txt']);
    f=figure,imshow(img);hold on; scatter(annotationsCropped(find(annotationsCropped(:,1)~=-1),1),annotationsCropped(find(annotationsCropped(:,2)~=-1),2),'r','Filled');
    saveas(f,['/tmp/sarthaksharma/save_syn_images_keypoints_cropped/' ,imgDir(imgNum).name(1:end-4) ,'.png']);close all;
    
end
%% Save the background overlayed and cropped images

%specify the image directory.
imgDir = dir('/tmp/sarthaksharma/syn_images_keypoints_cropped_bkg_overlaid/*.jpg');
saveDir = '/tmp/sarthaksharma/save_syn_images_keypoints_cropped_bkg_overlaid';

if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

for imgNum = 1:size(imgDir,1)
    
    
    img = imread(['/tmp/sarthaksharma/syn_images_keypoints_cropped_bkg_overlaid/' ,imgDir(imgNum).name]);
    annotationsBackgroundCropped =  importdata(['../data/syn_keypoint_annotations_cropped_bkg_overlaid/',imgDir(imgNum).name(1:end-4),'.txt']);
    f=figure,imshow(img);hold on; scatter(annotationsBackgroundCropped(find(annotationsBackgroundCropped(:,1)~=-1),1),annotationsBackgroundCropped(find(annotationsBackgroundCropped(:,2)~=-1),2),'r','Filled');
    saveas(f,['/tmp/sarthaksharma/save_syn_images_keypoints_cropped_bkg_overlaid/' ,imgDir(imgNum).name(1:end-4) ,'.png']);close all;
    
end