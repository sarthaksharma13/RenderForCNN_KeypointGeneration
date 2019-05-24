%% Script to crop all rendered images for a particular class

if ~exist('RENDER4CNN_ROOT', 'var')
    run('kde/setup_path.m');
end

addpath(fullfile(RENDER4CNN_ROOT, 'render_pipeline'));

% We're interested in the 'chair' class
sysnet_id = '03001627';
class_id = 'chair';

%% Setup data

% A few working directory paths
% src_folder = fullfile(RENDER4CNN_ROOT, 'data', 'syn_images', sysnet_id);
src_folder = fullfile(RENDER4CNN_ROOT, 'data', 'syn_images_keypoints');
% dst_folder = fullfile(RENDER4CNN_ROOT, 'data', 'syn_images_cropped', sysnet_id);
dst_folder = fullfile(RENDER4CNN_ROOT, 'data', 'syn_images_keypoints_cropped');
truncation_dist_file = fullfile(g_truncation_distribution_folder, [class_id, '.txt']);

if ~exist(dst_folder, 'dir')
    mkdir(dst_folder);
end

% Run the crop script (the last parameter is set to 0, which indicates that
% the code is not to be run on a single thread)
% crop_images(src_folder, dst_folder, truncation_dist_file, 0);

% Number of parallel threads
num_workers = 8;

% Get a list of image files
if ~exist('image_files', 'var')
    fprintf('Getting image list ... Takes a while this one ...\n');
    % image_files = rdir(fullfile(src_folder,'*/*.png'));
    image_files = rdir(fullfile(src_folder,'*.png'));
end
image_num = length(image_files);
fprintf('%d images in total.\n', image_num);

% Seeding RNG, for repeatability
rng('shuffle');

% Get the learnt truncation distribution
if ~exist('truncation_parameters', 'var')
    truncation_parameters = importdata(truncation_dist_file);
end
% Choose a subset of the truncation parameters
truncation_parameters_sub = truncation_parameters(randi([1, length(truncation_parameters)], 1, image_num), :);


%% Perform cropping

fprintf('Start croping at time %s...it takes for a while!!\n', datestr(now, 'HH:MM:SS'));

report_num = 80;
fprintf([repmat('.', 1, report_num) '\n\n']);
report_step = floor((image_num + report_num - 1) / report_num);
t_begin = clock;
successful_files = 0;

% Parallel for loop
% parfor(i = 1:image_num, 1)
for i = 1
    
    % Get the filename for the current image
    src_image_file = image_files(i).name;
    
    % Check if the current image has already been cropped
    dst_image_file = strrep(src_image_file, src_folder, dst_folder);
    
    % If it has, then continue
    if ~exist(dst_image_file, 'file')
        % Try reading in the image
        try
            [I, ~, alpha] = imread(src_image_file);
        catch
            fprintf('Failed to read %s\n', src_image_file);
        end
        
        % Try cropping the image
        try
            % [alpha, top, bottom, left, right] = crop_gray(alpha, 0, truncation_parameters_sub(i,:));
            [alpha, top, bottom, left, right] = crop_gray(alpha, 0, [-0.1,0.1,-0.1,0.1]);
            I = I(top:bottom, left:right, :);
            if numel(I) == 0
                fprintf('Failed to crop %s (empty image after crop)\n', src_image_file);
            else
                [dst_image_file_folder, ~, ~] = fileparts(dst_image_file);
                if ~exist(dst_image_file_folder, 'dir')
                    mkdir(dst_image_file_folder);
                end
                imwrite(I, dst_image_file, 'png', 'Alpha', alpha);
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
fprintf('%f seconds spent on cropping!\n', etime(t_end, t_begin));
fprintf('%d files successfully cropped!\n', successful_files);
