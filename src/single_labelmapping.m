function [ newid ] = single_labelmapping( label2map, oldid)
%SINGLE_LABELMAP Summary of this function goes here
%   label2map = true: label to 1, ..., N
%             = false: 1,...,N to label
load data/ids53.mat
if label2map
    if isempty(find(ids == oldid))
        oldid = 0; % null
    end
    newid = find(ids == oldid);
else
    newid = ids(oldid);
end
end

