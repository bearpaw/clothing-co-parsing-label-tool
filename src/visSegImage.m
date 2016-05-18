function I_s = visSegImage(im, labelmap)

% Show Segmentation Result

    [cx,cy] = gradient(double(labelmap));

    bdry_corr_hyper = abs(cx) + abs(cy) > 0;

    im_r = im(:, :, 1);
    im_g = im(:, :, 2);
    im_b = im(:, :, 3);
    im_r(bdry_corr_hyper) = 255;
    im_g(bdry_corr_hyper) = 255;
    im_b(bdry_corr_hyper) = 255;

    I_s = zeros(size(im));
    I_s(:, :, 1) = im_r;
    I_s(:, :, 2) = im_g;
    I_s(:, :, 3) = im_b; 
end