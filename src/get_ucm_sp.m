function [labelmap edgemap] = get_ucm_sp(ucm2, labelmap_thresh)
% %load double sized ucm
% load('data\normalization\annotated\ucm\000013_ucm2.mat','ucm2');

% convert ucm to the size of the original image
ucm = ucm2(3:2:end, 3:2:end);
minval = min(min(ucm));

edgemap = ucm;

% get the partition at scale k without boundaries:
% % labels2 = bwlabel(ucm2 <= k);

% get the partition at scale k without boundaries:
if nargin <2
    labelmap_thresh = minval;
end
labels2 = bwlabel(ucm2 <= labelmap_thresh);
labelmap = labels2(2:2:end, 2:2:end);

end