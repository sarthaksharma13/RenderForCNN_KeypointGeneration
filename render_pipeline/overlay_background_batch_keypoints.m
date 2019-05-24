%% Script to overlay background for a cropped batch
% Sarthak Sharma.
% Earlier the script used to load the cropped images and overlay it on
% background without any control on the final size of the image. In order
% to traint the hourglass images,we need a particular dimension(64x64).
% Hence modifying the final images,as well as the annotations according
% to that size.
%%
clc;close all;clear all;

% We're interested in the 'car' class
sysnet_id = '02958343';
class_id = 'car';

% Path to the SUN 2012 dataset in Pascal format
SUN_PASCAL_ROOT = fullfile('/media','data','data', 'datasets', 'SUN2012pascalformat');

% Desired dimension
w=64;
h=64;

%% Setup : A few working directory paths

% Source and destination folders for images.
src_folder = fullfile('/tmp', 'sarthaksharma', 'syn_images_keypoints_cropped');
dst_folder = fullfile('/tmp', 'sarthaksharma', 'syn_images_keypoints_cropped_bkg_overlaid');

% Source and destination folders for annotations
annot_src_folder = fullfile('/tmp/sarthaksharma/syn_keypoint_annotations_cropped');
annot_dst_folder = fullfile('/tmp/sarthaksharma/syn_keypoint_annotations_cropped_bkg_overlaid');

% Load the background file list.
bkg_file_list = fullfile(SUN_PASCAL_ROOT, 'filelist.txt');
bkg_folder = fullfile(SUN_PASCAL_ROOT, 'JPEGImages');
cluttered_bkg_ratio = 0.8;

% Number of parallel threads
num_workers = 8;

% Get a list of image files
if ~exist('image_files', 'var')
    fprintf('Getting image list ... Takes a while this one ...\n');
    % image_files = rdir(fullfile(src_folder,'*/*.png'));
    image_files = rdir(fullfile(src_folder,'*.png'));
end
% Make the annotation destination folder if not present. Not making the
% folder to store images here. It is made inside the main loop.
if ~exist(annot_dst_folder, 'dir')
    mkdir(annot_dst_folder);
end

% Total numberof images.
image_num = length(image_files);
fprintf('%d images in total.\n', image_num);

% Get the list of images in the SUN dataset
sun_image_list = importdata(bkg_file_list);

% Seeding RNG, for repeatability
rng('shuffle');
%% Perform cropping
fprintf('Start overlaying images at time %s, it takes for a while...\n', datestr(now, 'HH:MM:SS'));

% For displating the progress after some itterations. Also to record the
% total time taken to run the code.
report_num = 80;
fprintf([repmat('.',1,report_num) '\n\n']);
report_step = floor((image_num+report_num-1)/report_num);
successful_files = 0;
t_begin = clock;

parfor(i = 1:image_num, 1)
    
    % Get the filename for the current image
    src_image_file = image_files(i).name;
    
    % Check if the current image has already been cropped
    dst_image_file = strrep(src_image_file, src_folder, dst_folder);
    
    % Change the extension to .jpg from .png
    dst_image_file(end-3:end) = '.jpg';
    
    % If it has, then continue
    if ~exist(dst_image_file, 'file')
        % Try reading in the image
        try
            % Read the annotations and the images.
            [I, ~, alpha] = imread(src_image_file);
            
            kpFile = strsplit(src_image_file,'/');
            kpFile = kpFile(end);
            kpFile = kpFile{1};
            kpFile = kpFile(1:end-4);% Removing the images extension.
            kps = importdata(fullfile(annot_src_folder, [kpFile, '.txt']));
            
            % Destination file to store the annotations.
            dst_annot_file = fullfile(annot_dst_folder, [kpFile, '.txt']);
            
        catch
            fprintf('Failed to read %s\n', src_image_file);
        end
        
        % Try overlaying the image
        try
            s = size(I);
            fh = s(1); fw = s(2);
            mask = double(alpha) / 255; % alpha is transparency,output when reading the .png files.
            mask = repmat(mask,1,1,3);
            
            if rand() > cluttered_bkg_ratio
                I = uint8(double(I) .* mask + double(rand()*255) * (1 - mask));
            else
                while true
                    
                    % Select a random background image from the SUNLIST
                    % dataset.
                    id = randi(length(sun_image_list));
                    bg = imread(fullfile(bkg_folder, sun_image_list{id}));
                    s = size(bg);
                    bh = s(1); bw = s(2);
                    
                    % Background cant be smaller than the image.
                    if bh < fh || bw < fw
                        continue;
                    end
                    
                    % Background image can not greyscale.
                    if length(s) < 3
                        continue;
                    end
                    
                    % Else a valid background. Break and overlay.
                    break;
                end
                
                by = randi(bh - fh + 1);
                bx = randi(bw - fw + 1);
                bgcrop = bg(by:(by+fh-1), bx:(bx+fw-1), :);
                
                I = uint8(double(I) .* mask + double(bgcrop) .* (1 - mask));
            end
            
            if numel(I) == 0
                fprintf('Failed to crop %s (empty image after crop)\n', src_image_file);
            else
                
                [dst_image_file_folder, ~, ~] = fileparts(dst_image_file);

                % Create the folder to store the images HERE.
                if ~exist(dst_image_file_folder, 'dir')
                    mkdir(dst_image_file_folder);
                end
                
                % Resize to the desired dimension.
                initial_height = size(I,1)% Height is the number of rows.
                initial_width = size(I,2) % Width is the number of columns.
                
                I = imresize(I,[w,h]);
                
                % Change the keypoints accordingly.
                kps(:,1)= (kps(:,1)/initial_width)*w;
                kps(:,2)= (kps(:,2)/initial_height)*h;
                
                % Some entries of the keypoints from the cropped image
                % might have had been -1(read the comments in
                % crop_images_batch_keypoints.m), hence deal with these
                % negative entries now.
                outlierX = find(kps(:,1)<1); 
                outlierY = find(kps(:,2)<1);
                
                % Make the entry as (-1,-1)
                kps(union(outlierX, outlierY),1) = -1;
                kps(union(outlierX, outlierY),2) = -1;
                
                
               
                % Write the keypoints and the images.
                imwrite(I, dst_image_file, 'jpg');
                annotOutFile = fopen(dst_annot_file, 'w');
                for j = 1:size(kps,1)
                    fprintf(annotOutFile, '%f %f \n', kps(j,1), kps(j,2));
                end
                fclose(annotOutFile);
                
                successful_files = successful_files + 1;
            end
        catch
        end
    else
        successful_files = successful_files + 1;
    end
    
    if mod(i, report_step) == 0
        fprintf('\b|\n');
    end
    
end

t_end = clock;
fprintf('%f Seconds spent on cropping!\n', etime(t_end, t_begin));
fprintf('%d Total number of input images : \n', image_num);
fprintf('%d Images successfully overlayed!\n', successful_files);
