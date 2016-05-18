function gt_image = demo(name)
% color map
colors = colormap(jet(57));

% Define label names
clothings = cell(1, 2);
clothings{1} = (0:56);
names = {'background', 'accessories', 'bag', 'belt', 'blazer', 'blouse', 'bodysuit', 'brassiere', ...
    'bracelet', 'cape', 'cardigan', 'coat', 'dress', 'glasses', 'gloves', 'hair', 'hat', 'jacket', ...
    'jeans', 'jumper', 'leggings', 'necklace', 'pants', 'purse', 'ring', 'romper', 'scarf', 'shirt', 'shoes',...
    'shorts', 'skin', 'skirt', 'socks', 'stockings', 'suit', 'sunglasses', 'sweater', 'sweatshirt', 'tshirt',...
    'tie', 'tights', 'top', 'vest', 'wallet', 'boots', 'clogs', 'earrings', 'flats', 'heels', 'hoodie', ...
    'loafers', 'panties', 'pumps', 'sandals', 'sneakers', 'swimwear', 'watch', 'wedges'...
    };

clothings{2} = names;

% image name
% name = '00682433930a5807648f3a9d4861e691_w550';

% load original photo
photo = imread(['selected_full//' name '.jpg']);

% load superpixles
load(['selected_ucm/' name '_ucm2.mat'], 'ucm2');       
[labelmap edgemap] = get_ucm_sp(ucm2, 0.03);

% load superpixel-level groundtruth
load(['pixel-level/' name '.mat'], 'groundtruth');

% get image-level labels
labels = unique(groundtruth);
label_names = cell(1, length(labels));
for i = 1:length(labels)
    label_names(i) = clothings{2}(find(clothings{1} == labels(i)));
end
label_names;

% show original photo
demo_figure = figure; scrsz = get(0,'ScreenSize'); set(gcf,'Position',scrsz); % maximize figure window
subplot(1, 4, 1);  imshow(photo); hold on; title('Original'); 

% show superpixels
subplot(1, 4, 2); imshow(uint8(labelmap/max(labelmap(:))*255)); hold on;title('Superpixels'); 



% visualize superpixel-level groundtruth
gt_image = visualize(colors, labelmap, groundtruth);
subplot(1, 4, 3); 
imshow(gt_image); hold on; title('Ground Truth'); 

% visualize image-level labels
subplot(1, 4, 4); 
axis off; hold on; % show off the axis 
for i=1:length(labels)
    if(labels(i) == 0)
        [rows cols] = find(groundtruth == labels(i));
        plot(cols, rows, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0, 0, 0], 'MarkerSize', 10, 'visible', 'off');
        continue;
    end
    [rows cols] = find(groundtruth == labels(i));
    plot(cols, rows, 's', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(labels(i), :), 'MarkerSize', 10, 'visible', 'off');
end
set(gca, 'Ydir', 'reverse'); hold off;
lh = legend(label_names, 'Location', 'West');
pause; close(demo_figure);
end




