function readmap
% load ucm as map
load('ucm/0000e37856a7c65ee687edcc001ec842_w550_ucm2.mat', 'ucm2');

% convert ucm to the size of the original image
ucm = ucm2(3:2:end, 3:2:end);

% get the boundaries of segmentation at scale k in range [0 1]
k = 0.05;
bdry = (ucm >= k);

% get the partition at scale k without boundaries:
labels2 = bwlabel(ucm2 <= k);
labels = labels2(2:2:end, 2:2:end);


figure;imshow(ucm);
figure;imshow(bdry);
figure;imshow(labels,[]);colormap(jet);

length(unique(labels))

end