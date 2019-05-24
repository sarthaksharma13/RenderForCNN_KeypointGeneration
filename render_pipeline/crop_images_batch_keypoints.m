%% Script to crop all rendered images for a particular class. Slightly modifed to 
% remove the keypoints that might not lie inside the image after cropping.
% Rest all is same. Assumes that you ahve run the files 'run_sampling.m'
% ,'global_variables.m' and 'setup.py' with the class you have in mind.
% This would lead to generation of certain inmportant text file : namely
% the statistics file for viewpoint as well as truncations.

% Sarthak Sharma

%%

clc;close all;clear all;
if ~exist('RENDER4CNN_ROOT', 'var')
    run('kde/setup_path.m');
end
addpath(fullfile(RENDER4CNN_ROOT, 'render_pipeline'));

% We're interested in the 'car' class
sysnet_id = '02958343';
class_id = 'car';
%%%
% IMP : SET THE CLASS ID IN RUN_SAMPLING.M ,GLOBAL_VARIABLES.M and
% SETUP.PY
%%%

%% Setup data
% A few working directory paths
src_folder = fullfile('/tmp', 'sarthaksharma', 'syn_images_keypoints');
dst_folder = fullfile('/tmp', 'sarthaksharma', 'syn_images_keypoints_cropped');

% Source and destination folders for annotations
annot_src_folder = fullfile('/tmp/sarthaksharma/syn_keypoint_annotations');
annot_dst_folder = fullfile('/tmp/sarthaksharma/syn_keypoint_annotations_cropped');

% Load the truncation distribution for that class.
truncation_dist_file = fullfile(g_truncation_distribution_folder, [class_id, '.txt']);

% Make the directories as required.
if ~exist(dst_folder, 'dir')
    mkdir(dst_folder);
end
if ~exist(annot_dst_folder, 'dir')
    mkdir(annot_dst_folder);
end

% Run the crop script (the last parameter is set to 0, which indicates that
% the code is not to be run on a single thread)
% crop_images(src_folder, dst_folder, truncation_dist_file, 0);

% Number of parallel threads
num_workers = 8;

% Get a list of image files
if ~exist('image_files', 'var')
    fprintf('Getting image list ... Takes a while this one ...\n');
    image_files = rdir(fullfile(src_folder,'*.png'));
end
% Number of images.
image_num = length(image_files);
fprintf('%d images in total.\n', image_num);

% Seeding RNG, for repeatability
rng('shuffle');

% Get the learnt truncation distribution
if ~exist('truncation_parameters', 'var')
    truncation_parameters = importdata(truncation_dist_file);
    disp('l');
end

% Choose a subset of the truncation parameters
truncation_parameters_sub = truncation_parameters(randi([1, length(truncation_parameters)], 1, image_num), :);


%% Perform cropping
fprintf('Start croping at time %s...it takes for a while!!\n', datestr(now, 'HH:MM:SS'));

% To keep track of what is happening.
report_num = 80;
fprintf([repmat('.', 1, report_num) '\n\n']);
report_step = floor((image_num + report_num - 1) / report_num);
t_begin = clock;
successful_files = 0;

% Parallel for loop
parfor i = 1:image_num 
    
%     fprintf(['Done : ', num2str(i) , ' out of ',num2str(image_num) ,'\n' ]);
    
    % Get the filename for the current image
    src_image_file = image_files(i).name;
    
    % Check if the current image has already been cropped
    dst_image_file = strrep(src_image_file, src_folder, dst_folder);
    
    % If it has, then continue
    if ~exist(dst_image_file, 'file')
        % Try reading in the image and the keypoint annotations
        
        try
            [I, ~, alpha] = imread(src_image_file);
            
            % Read the keypoint file. Note that tranpose is taken,hence it
            % becomes 2xNumKps.
            src_image_file
            kpFile = strsplit(src_image_file,'/')
            kpFile = kpFile(end);
            kpFile = kpFile{1};
            kpFile = kpFile(1:end-4);
            kps = importdata(fullfile(annot_src_folder, [kpFile, '.txt']))';
            dst_annot_file = fullfile(annot_dst_folder, [kpFile, '.txt']);
            
        catch
            fprintf('Failed to read %s\n', src_image_file);
        end
        
        % Try cropping the image
        try
            
            [alpha, top, bottom, left, right] = crop_gray(alpha, 0, truncation_parameters_sub(i,:));
            size(kps);
            kps = kps - repmat([left;top], 1, size(kps,2));
            
            I = I(top:bottom, left:right, :);
            
            if numel(I) == 0
                fprintf('Failed to crop %s (empty image after crop)\n', src_image_file);
            else
                % Write the image file.
                [dst_image_file_folder, ~, ~] = fileparts(dst_image_file);
                if ~exist(dst_image_file_folder, 'dir')
                    mkdir(dst_image_file_folder);
                end
                imwrite(I, dst_image_file, 'png', 'Alpha', alpha);
              
                
                
                
                % Before writing the keypoints,we need to check that the 
                % keypoints lie inside the image. If either of the X or Y
                % coordinate is off,make the entire entry ,i.e the whole keypoint 
                % as (-1,-1).
                
                width = size(I,2); height = size(I,1);
                outlierX = union(find(kps(1,:)>=width),find(kps(1,:)<1)); 
                outlierY = union(find(kps(2,:)>=height),find(kps(2,:)<1));
                
                % Make the entry as (-1,-1)
                kps(1,union(outlierX, outlierY)) = -1;
                kps(2,union(outlierX, outlierY)) = -1;
                disp('lol');
                fprintf(dst_annot_file)
                % Write the annotation file.
                annotOutFile = fopen(dst_annot_file, 'w');
                for j = 1:size(kps,2)
                    fprintf(annotOutFile, '%f %f \n', kps(1,j), kps(2,j));
                end
                
                
                successful_files = successful_files + 1;
            end
        catch
            disp('Fail');
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
fprintf('%d Total number of input images!\n', image_num);
fprintf('%d Images successfully cropped!\n', successful_files);
