function [ scratch ] = vissegment( segMap, img )
%VISSEGMENT Summary of this function goes here
%   Detailed explanation goes here
if ~isempty(img)
    scratch = img;
else
    scratch = zeros(size(segMap,1), size(segMap,2), 3, 'uint8');
end

col = [.5 .25 1;
    0 0 1;
    0 1 0;
    1 0.5 0;
    1 0 0;
    0 0.5 1;
    1 0 0.5;
    0.5 1 0;
    .5 .5 .5;
    0 0 .25;
    0 .25 0;
    .25 0.5 0;
    .25 0 0;
    0 0.5 .25;
    .25 0 0.5;
    0.5 .25 0;
    .25 .25 .25;
    0 0 .5;
    0 .5 0;
    .5 0.5 0;
    .5 0 0;
    0 0 0;
    .5 0 0.5;
    0.25 1 0 ];
label = unique(segMap);
if isempty(img)
    for j = 1 : length(label)
        i = label(j);
        s = scratch(:,:,1);
        s(segMap == i) = 255*col(i+1,1);
        scratch(:,:,1) = s;
        s = scratch(:,:,2);
        s(segMap == i) = 255*col(i+1,2);
        scratch(:,:,2) = s;
        s = scratch(:,:,3);
        s(segMap == i) = 255*col(i+1,3);
        scratch(:,:,3) = s;
    end
else
    for j = 1 : length(label)
        i = label(j);
        s = scratch(:,:,1);
        s(segMap == i) = s(segMap == i)/2 + .5*col(i+1,1);
        scratch(:,:,1) = s;
        s = scratch(:,:,2);
        s(segMap == i) = s(segMap == i)/2 +.5*col(i+1,2);
        scratch(:,:,2) = s;
        s = scratch(:,:,3);
        s(segMap == i) = s(segMap == i)/2+ .5*col(i+1,3);
        scratch(:,:,3) = s;
    end
end

end

