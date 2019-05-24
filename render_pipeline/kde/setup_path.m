% add paths
RENDER4CNN_ROOT_TEMP = strsplit(fullfile(mfilename('fullpath')), '/');
RENDER4CNN_ROOT = RENDER4CNN_ROOT_TEMP(1);
for i = 2:length(RENDER4CNN_ROOT_TEMP)-1
    RENDER4CNN_ROOT = strcat(RENDER4CNN_ROOT, '/', RENDER4CNN_ROOT_TEMP(i));
end
clear RENDER4CNN_ROOT_TEMP
RENDER4CNN_ROOT = strcat(RENDER4CNN_ROOT, '/../../');
RENDER4CNN_ROOT = RENDER4CNN_ROOT{1};
% RENDER4CNN_ROOT = fullfile(mfilename('fullpath'),'../../../')

PASCAL3D_DIR = fullfile('/media/data/data/datasets/PASCAL3D');
% PASCAL3D_DIR = fullfile(RENDER4CNN_ROOT, 'datasets/pascal3d/');
addpath(fullfile(PASCAL3D_DIR, 'VDPM'));
addpath(fullfile(PASCAL3D_DIR, 'Annotation_tools'));
addpath(RENDER4CNN_ROOT);
global_variables;

% initialize the PASCAL development kit 
tmp = pwd;
cd(fullfile(PASCAL3D_DIR, 'PASCAL/VOCdevkit'));
addpath([cd '/VOCcode']);
VOCinit;
cd(tmp);
