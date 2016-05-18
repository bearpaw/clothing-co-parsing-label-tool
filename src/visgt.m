function imgt = visgt(colors, labelmap, groundtruth)
% colors = [.5 .25 1;
%     0 0 1;
%     0 1 0;
%     1 0.5 0;
%     1 0 0;
%     0 0.5 1;
%     1 0 0.5;
%     0.5 1 0;
%     .5 .5 .5;
%     0 0 .25;
%     0 .25 0;
%     .25 0.5 0;
%     .25 0 0;
%     0 0.5 .25;
%     .25 0 0.5;
%     0.5 .25 0;
%     .25 .25 .25;
%     0 0 .5;
%     0 .5 0;
%     .5 0.5 0;
%     .5 0 0;
%     0 .5 .5;
%     .5 0 0.5;
%     0.25 1 0;
%     .1 .5 .9;
%     .1 .9 .5;
%     .5 .1 .9;
%     .5 .9 .1;
%     .9 .5 .1;
%     .9 .1 .5;
%     .3 .6 .9;
%     .3 .9 .6;
%     .6 .3 .9;
%     .6 .9 .3;
%     .9 .3 .6;
%     .9 .6 .3;
%     .15 .75 1;
%     .15 1 .75;
%     .75 .15 1;
%     .75 1 .15;
%     1 .15 .75;
%     1 .75 .15;
%     1.25 1 .3];

imgt = zeros(size(labelmap, 1), size(labelmap, 2), 3);

for curlabel = 1:length(unique(labelmap))
    [rows cols] = find(labelmap == curlabel);
    if groundtruth(curlabel)~=0
        curcolor = colors(groundtruth(curlabel), :);
        for i=1:length(rows)
            imgt(rows(i), cols(i), 1) = curcolor(1);
            imgt(rows(i), cols(i), 2) = curcolor(2);
            imgt(rows(i), cols(i), 3) = curcolor(3);
        end
    end
end