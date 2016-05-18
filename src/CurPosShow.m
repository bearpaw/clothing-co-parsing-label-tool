function CurPosShow(hObject, eventdata, OpSet)
% Show (On/Off) the Cursor Position on the Current Axes
% OpSet = 'on' or 'off'
% the axes tag is '**n' ,and textbox' tag should be 'TXn' and 'TYn'
% Version   1.0Bata
% CopyRight WEI Zhen 2010-2014
global lastlabel colors
handles=guidata(gcbo);                                    % get handles
X=get(gca,'XLim');                                             % x range of current axes 
Xmin=X(1);
Xmax=X(2);
Y=get(gca,'YLim');                                              % y range of current axes 
Ymin=Y(1);
Ymax=Y(2);
AxName=get(gca,'Tag');                                    % name of the current axes
hTX=findobj(gcf,'tag',['TX']);        % find correspond text box x
hTY=findobj(gcf,'tag',['TY']);         % find correspond text box y
%
set(gcf,'windowbuttonmotionfcn','');                  % dissable all callback in figure
set(gcf,'windowbuttonmotionfcn',{@CurPosShow, 'on'}); % set callback when mouse move

switch OpSet
case 'on'
   curPos = get(gca, 'CurrentPoint');
   pX=max([Xmin curPos(1,1)]);
   pX=min([Xmax pX]);
   pY=max([Ymin curPos(1,2)]);
   pY=min([Ymax pY]);
   set(hTX,'String',pX);
   set(hTY,'String',pY);
%    
%    
% %% tagging
% col = uint32(pX);
% row = uint32(pY);
% 
% curlabel = labelmap(row, col)
% lastlabel
% 
% % eraser
% if strcmp(get(get(handles.btnGroup,'SelectedObject'),'Tag'), 'eraser') == 1
%     [rows cols] = find(labelmap == curlabel);
%     for i=1:length(rows)
%         I(rows(i), cols(i), 1) = im(rows(i), cols(i), 1);
%         I(rows(i), cols(i), 2) = im(rows(i), cols(i), 2);
%         I(rows(i), cols(i), 3) = im(rows(i), cols(i), 3);
%     end
%     lastlabel = 0;
%     
% end
% 
% if curlabel ~= lastlabel
%     switch get(get(handles.btnGroup,'SelectedObject'),'Tag')
%         case 'hair_rb', curcolor = colors(1, :);
%         case 'hat_rb', curcolor = colors(2, :);
%         case 'face_rb', curcolor = colors(3, :);
%         case 'skin_rb', curcolor = colors(4, :);
%         case 'coat_rb', curcolor = colors(5, :);
%         case 'tshirt_rb', curcolor = colors(6, :);
%         case 'bag_rb', curcolor = colors(7, :);
%         case 'dress_rb', curcolor = colors(8, :);
%         case 'trouser_rb', curcolor = colors(9, :);
%         case 'short_rb', curcolor = colors(10, :);
%         case 'skirt_rb', curcolor = colors(11, :);
%         case 'stock_rb', curcolor = colors(12, :);
%         case 'shoe_rb', curcolor = colors(13, :);
%     end
%     [rows cols] = find(labelmap == curlabel);
%     for i=1:length(rows)
%         I(rows(i), cols(i), 1) = curcolor(1);
%         I(rows(i), cols(i), 2) = curcolor(2);
%         I(rows(i), cols(i), 3) = curcolor(3);
%     end
%     axes(handles.image);%axes1是坐标轴的标示
% 
%     hImg = imshow(I,[]);
%     set(hImg,'ButtonDownFcn',{@ImgButtonDown,handles, im, labelmap, I});
%     
%     lastlabel = curlabel;
% end

case 'off' 
   set(gcf,'windowbuttonmotionfcn','');             % dissable callback
end
guidata(gcbo,handles);                              % save handles (refresh)

