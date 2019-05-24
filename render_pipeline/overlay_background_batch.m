%% Script to overlay background for a cropped batch

addpath(fullfile(RENDER4CNN_ROOT, 'render_pipeline'));

% We're interested in the 'chair' class
sysnet_id = '03001627';
class_id = 'chair';

% Path to the SUN 2012 dataset in Pascal format
SUN_PASCAL_ROOT = fullfile('/home', 'data', 'datasets', 'SUN2012pascalformat');


%% Setup

% A few working directory paths
% src_folder = fullfile(RENDER4CNN_ROOT, 'data', 'syn_images_cropped', sysnet_id);
src_folder = fullfile(RENDER4CNN_ROOT, 'data', 'syn_images_keypoints_cropped');
% dst_folder = fullfile(RENDER4CNN_ROOT, 'data', 'syn_images_cropped_bkg_overlaid', sysnet_id);
dst_folder = fullfile(RENDER4CNN_ROOT, 'data', 'syn_images_keypoints_cropped_bkg_overlaid');
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
image_num = length(image_files);
fprintf('%d images in total.\n', image_num);

% Get the list of images in the SUN dataset
sun_image_list = importdata(bkg_file_list);

% Seeding RNG, for repeatability
rng('shuffle');


% %% Perform cropping
% 
% fprintf('Start overlaying images at time %s, it takes for a while...\n', datestr(now, 'HH:MM:SS'));
% 
% report_num = 80;
% fprintf([repmat('.',1,report_num) '\n\n']);
% report_step = floor((image_num+report_num-1)/report_num);
% successful_files = 0;
% t_begin = clock;
% 
% % for i = 1
% parfor(i = 1:image_num, 1)
%     
%     % Get the filename for the current image
%     src_image_file = image_files(i).name;
%     
%     % Check if the current image has already been cropped
%     dst_image_file = strrep(src_image_file, src_folder, dst_folder);
%     
%     % If it has, then continue
%     if ~exist(dst_image_file, 'file')
%         % Try reading in the image
%         try
%             [I, ~, alpha] = imread(src_image_file);
%         catch
%             fprintf('Failed to read %s\n', src_image_file);
%         end
%         
%         % Try overlaying the image
%         try
%             s = size(I);
%             fh = s(1); fw = s(2);
%             mask = double(alpha) / 255;
%             mask = repmat(mask,1,1,3);
%             
%             if rand() > cluttered_bkg_ratio
%                 I = uint8(double(I) .* mask + double(rand()*255) * (1 - mask));
%             else
%                 while true
%                     id = randi(length(sun_image_list));
%                     bg = imread(fullfile(bkg_folder, sun_image_list{id}));
%                     s = size(bg);
%                     bh = s(1); bw = s(2);
%                     if bh < fh || bw < fw
%                         %fprintf(1, '.');
%                         continue;
%                     end
%                     if length(s) < 3
%                         continue;
%                     end
%                     break;
%                 end
%                 by = randi(bh - fh + 1);
%                 bx = randi(bw - fw + 1);
%                 bgcrop = bg(by:(by+fh-1), bx:(bx+fw-1), :);
%                 
%                 I = uint8(double(I) .* mask + double(bgcrop) .* (1 - mask));
%             end
%             
%             if numel(I) == 0
%                 fprintf('Failed to crop %s (empty image after crop)\n', src_image_file);
%             else
%                 [dst_image_file_folder, ~, ~] = fileparts(dst_image_file);
%                 if ~exist(dst_image_file_folder, 'dir')
%                     mkdir(dst_image_file_folder);
%                 end
%                 imwrite(I, dst_image_file, 'jpg');
%                 successful_files = successful_files + 1;
%             end
%         catch
%         end
%     else
%         successful_files = successful_files + 1;
%     end
%     
%     if mod(i, report_step) == 0
%         fprintf('\b|\n');
%     end
%     
% end
% 
% t_end = clock;
% fprintf('%f seconds spent on background overlay!\n', etime(t_end, t_begin));
