function imgt = visualize(colors, labelmap, groundtruth)
imgt = zeros(size(labelmap, 1), size(labelmap, 2), 3);

for curlabel = 1:length(unique(labelmap))
    [rows cols] = find(labelmap == curlabel);
    if groundtruth(curlabel) ~= 0
        curcolor = colors(groundtruth(curlabel), :);
        for i=1:length(rows)
            imgt(rows(i), cols(i), 1) = curcolor(1);
            imgt(rows(i), cols(i), 2) = curcolor(2);
            imgt(rows(i), cols(i), 3) = curcolor(3);
        end
    end
end