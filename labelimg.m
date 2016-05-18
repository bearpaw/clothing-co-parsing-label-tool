function varargout = labelimg(varargin)
% LABELIMG MATLAB code for labelimg.fig
%      LABELIMG, by itself, creates a new LABELIMG or raises the existing
%      singleton*.
%
%      H = LABELIMG returns the handle to a new LABELIMG or the handle to
%      the existing singleton*.
%
%      LABELIMG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABELIMG.M with the given input arguments.
%
%      LABELIMG('Property','Value',...) creates a new LABELIMG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before labelimg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to labelimg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help labelimg

% Last Modified by GUIDE v2.5 15-May-2014 17:33:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @labelimg_OpeningFcn, ...
                   'gui_OutputFcn',  @labelimg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before labelimg is made visible.
function labelimg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to labelimg (see VARARGIN)

% Choose default command line output for labelimg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes labelimg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = labelimg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in startBtn.
function startBtn_Callback(hObject, eventdata, handles)
% hObject    handle to startBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imlist;
global curnum;
startnum = get(handles.imgmenu,'Value');
curnum = startnum;

load_image(hObject, eventdata, handles)
%% load image

function load_image(hObject, eventdata, handles)
global imlist curnum name groundtruth shoes tagIDs colors
load('data/ids53');
load('data/clothings.mat');

[p name ext] = fileparts(imlist(curnum).name);

if exist(['image-level\', name, '.mat'], 'file')
    load(['image-level\' name '.mat']);
    labels = unique(Label);
    tagIDs = labels;
else
    labels = [];
    tagIDs = labels;
end

for i = 1:length(labels )
    % convert groundtruth
    labels(i) = single_labelmapping(true, labels(i));
end



tags = [];
for i = 1:length(labels)
    if ~isempty(find(shoes == labels(i)))
        tagname = 'shoes';
    else
        tagname = get_tag_name(single_labelmapping(false, labels(i)), clothings);
    end
    tags = [tags [tagname ' | ']];
end
tags = tags(1 : length(tags) - 3);

set(handles.titletext, 'String', [name ext]);
set(handles.tagtext, 'String', tags);

%% load image and ucm2
im = imread(['selected_full/' name ext]);
load(['selected_ucm/' name '_ucm2.mat'], 'ucm2');
[labelmap edgemap] = get_ucm_sp(ucm2, 0.03);

if exist(['pixel-level/', name, '.mat'], 'file')
    load(['pixel-level/' name '.mat']); % load groundtruth
else
    groundtruth = zeros(length(unique(labelmap)), 1);
end

I =  uint8(visSegImage( im, labelmap ));


% Modified by Rajesh
global segImg
segImg = I;

% restore 
gtids = unique(groundtruth);
for gtid = 1:length(gtids)
    curtagid = gtids(gtid);
    
    if curtagid == 0
        continue;
    else
        curcolor = colors(curtagid,:);
    end
    
    curgtcell = find(groundtruth == curtagid);
    for jj = 1:length(curgtcell)
        curlabel = curgtcell(jj);
        [rows cols] = find(labelmap == curlabel);
        for i=1:length(rows)
            I(rows(i), cols(i), 1) = curcolor(1);
            I(rows(i), cols(i), 2) = curcolor(2);
            I(rows(i), cols(i), 3) = curcolor(3);
        end
    end
end

axes(handles.image);
% Modified by Rajesh
% res = grs2rgb(labelmap,colormap(jet));
% I = 0.2*double(im/255) + 0.8*res;

% Right Big Image

axes(handles.image); %axes1��������
hImg = imshow(I,[]);
set(hImg,'ButtonDownFcn',{@ImgButtonDown,handles, im, labelmap, I});

% Left small image
axes(handles.thumbnail)
imshow(im);

% The original ImgButtonDown function commented on Oct. 23rd
% 
%function ImgButtonDown(hObject, eventdata, handles, im,  labelmap, I)
%global isdraw lastlabel colors name groundtruth
%if isdraw == false
%    CurPosShow(hObject, eventdata,'on');
%    isdraw = true;
%else
%    CurPosShow(hObject, eventdata,'off');
%    isdraw = false;
%end
%
%
%col = uint32(str2num( get(handles.TX, 'string')));
%row = uint32(str2num( get(handles.TY, 'string')));
%curlabel = labelmap(row, col)
%
% coat_rb
%if strcmp(get(get(handles.btnGroup,'SelectedObject'),'Tag'), 'coat_rb') == 1
%    [rows cols] = find(labelmap == curlabel);
%    for i=1:length(rows)
%        I(rows(i), cols(i), 1) = im(rows(i), cols(i), 1);
%        I(rows(i), cols(i), 2) = im(rows(i), cols(i), 2);
%        I(rows(i), cols(i), 3) = im(rows(i), cols(i), 3);
%    end
%
%    axes(handles.image);%axes1��������
%
%    hImg = imshow(I,[]);
%    set(hImg,'ButtonDownFcn',{@ImgButtonDown,handles, im, labelmap, I});
%    lastlabel = 0;
%    groundtruth(curlabel) = 0;
%    
%else
%    % tagging
%    if curlabel ~= lastlabel
%        switch get(get(handles.btnGroup,'SelectedObject'),'Tag')
%            case 'jumper_rb', curcolor = colors(1, :), groundtruth(curlabel) = 1;
%            case 'glasses_rb', curcolor = colors(2, :), groundtruth(curlabel) = 2;
%            case 'gloves_rb', curcolor = colors(3, :), groundtruth(curlabel) = 3;
%            case 'hair_rb', curcolor = colors(4, :), groundtruth(curlabel) = 4;
%            case 'hat_rb', curcolor = colors(5, :), groundtruth(curlabel) = 5;
%            case 'jacket_rb', curcolor = colors(6, :), groundtruth(curlabel) = 6;
%            case 'jeans_rb', curcolor = colors(7, :), groundtruth(curlabel) = 7;
%            case 'jumper_rb', curcolor = colors(8, :), groundtruth(curlabel) = 8;
%            case 'leggings_rb', curcolor = colors(9, :), groundtruth(curlabel) = 9;
%            case 'necklace_rb', curcolor = colors(10, :), groundtruth(curlabel) = 10;
%            case 'pants_rb', curcolor = colors(11, :), groundtruth(curlabel) = 11;
%            case 'purse_rb', curcolor = colors(12, :), groundtruth(curlabel) = 12;
%            case 'ring_rb', curcolor = colors(13, :), groundtruth(curlabel) = 13;
%        end
%        [rows cols] = find(labelmap == curlabel);
%        for i=1:length(rows)
%            I(rows(i), cols(i), 1) = curcolor(1);
%            I(rows(i), cols(i), 2) = curcolor(2);
%            I(rows(i), cols(i), 3) = curcolor(3);
%        end
%
%        axes(handles.image);%axes1��������
%
%        hImg = imshow(I,[]);
%        set(hImg,'ButtonDownFcn',{@ImgButtonDown,handles, im, labelmap, I});
%        lastlabel = curlabel;
%    end
%end




function ImgButtonDown(hObject, eventdata, handles, im,  labelmap, I)
global isLMBDown
isLMBDown = true;

set(handles.output, 'WindowButtonMotionFcn', {@ImgButtonMotion, handles, im, labelmap, I});
set(handles.output, 'WindowButtonUpFcn', {@ImgButtonUp, handles, im, labelmap, I});




function ImgButtonUp(hObject, eventdata, handles, im, labelmap, I)
global isLMBDown
isLMBDown = false;




function ImgButtonMotion(hObject, eventdata, handles, im, labelmap, I)
global isdraw lastlabel colors name groundtruth isLMBDown segImg

if isLMBDown
%    if isdraw == false
%        CurPosShow(hObject, eventdata,'on');
%        isdraw = true;
%    else
%        CurPosShow(hObject, eventdata,'off');
%        isdraw = false;
%    end
    
    cp = get(gca, 'CurrentPoint');
    col = uint32(cp(1, 1));
    row = uint32(cp(1, 2));
    curlabel = labelmap(row, col);

    % erase 
    if strcmp(get(get(handles.btnGroup,'SelectedObject'),'Tag'), 'efface_rb') == 1
        [rows cols] = find(labelmap == curlabel);
        for i=1:length(rows)
            I(rows(i), cols(i), 1) = segImg(rows(i), cols(i), 1);
            I(rows(i), cols(i), 2) = segImg(rows(i), cols(i), 2);
            I(rows(i), cols(i), 3) = segImg(rows(i), cols(i), 3);
        end

        axes(handles.image);

        hImg = imshow(I,[]);
        set(hImg,'ButtonDownFcn',{@ImgButtonDown,handles, im, labelmap, I});
        set(handles.output, 'WindowButtonMotionFcn', {@ImgButtonMotion, handles, im, labelmap, I});
        lastlabel = 0;
        groundtruth(curlabel) = 0;

    else
        % tagging
        if curlabel ~= lastlabel
            switch get(get(handles.btnGroup,'SelectedObject'),'Tag')
                case 'accessories_rb'
                    curcolor = colors(1, :);
                    groundtruth(curlabel) = 1;
                case 'bag_rb'
                    curcolor = colors(2, :);
                    groundtruth(curlabel) = 2;
                case 'belt_rb'
                    curcolor = colors(3, :);
                    groundtruth(curlabel) = 3;
                case 'blazer_rb'
                    curcolor = colors(4, :);
                    groundtruth(curlabel) = 4;
                case 'blouse_rb'
                    curcolor = colors(5, :);
                    groundtruth(curlabel) = 5;
                case 'bodysuit_rb'
                    curcolor = colors(6, :);
                    groundtruth(curlabel) = 6;
                case 'brassiere_rb'
                    curcolor = colors(7, :);
                    groundtruth(curlabel) = 7;
                case 'bracelet_rb'
                    curcolor = colors(8, :);
                    groundtruth(curlabel) = 8;
                case 'cape_rb'
                    curcolor = colors(9, :);
                    groundtruth(curlabel) = 9;
                case 'cardigan_rb'
                    curcolor = colors(10, :);
                    groundtruth(curlabel) = 10;
                case 'coat_rb'
                    curcolor = colors(11, :);
                    groundtruth(curlabel) = 11;
                case 'dress_rb'
                    curcolor = colors(12, :);
                    groundtruth(curlabel) = 12;
                case 'glasses_rb'
                    curcolor = colors(13, :);
                    groundtruth(curlabel) = 13;
                case 'gloves_rb'
                    curcolor = colors(14, :);
                    groundtruth(curlabel) = 14;
                case 'hair_rb'
                    curcolor = colors(15, :);
                    groundtruth(curlabel) = 15;
                case 'hat_rb'
                    curcolor = colors(16, :);
                    groundtruth(curlabel) = 16;
                case 'jacket_rb'
                    curcolor = colors(17, :);
                    groundtruth(curlabel) = 17;
                case 'jeans_rb'
                    curcolor = colors(18, :);
                    groundtruth(curlabel) = 18;
                case 'jumper_rb'
                    curcolor = colors(19, :);
                    groundtruth(curlabel) = 19;
                case 'leggings_rb'
                    curcolor = colors(20, :);
                    groundtruth(curlabel) = 20;
                case 'necklace_rb'
                    curcolor = colors(21, :);
                    groundtruth(curlabel) = 21;
                case 'pants_rb'
                    curcolor = colors(22, :);
                    groundtruth(curlabel) = 22;
                case 'purse_rb'
                    curcolor = colors(23, :);
                    groundtruth(curlabel) = 23;
                case 'ring_rb'
                    curcolor = colors(24, :);
                    groundtruth(curlabel) = 24;
                case 'romper_rb'
                    curcolor = colors(25, :);
                    groundtruth(curlabel) = 25;
                case 'scarf_rb'
                    curcolor = colors(26, :);
                    groundtruth(curlabel) = 26;
                case 'shirt_rb'
                    curcolor = colors(27, :);
                    groundtruth(curlabel) = 27;
                case 'shoes_rb'
                    curcolor = colors(28, :);
                    groundtruth(curlabel) = 28;
                case 'shorts_rb'
                    curcolor = colors(29, :);
                    groundtruth(curlabel) = 29;
                case 'skin_rb'
                    curcolor = colors(30, :);
                    groundtruth(curlabel) = 30;
                case 'skirt_rb'
                    curcolor = colors(31, :);
                    groundtruth(curlabel) = 31;
                case 'socks_rb'
                    curcolor = colors(32, :);
                    groundtruth(curlabel) = 32;
                case 'stockings_rb'
                    curcolor = colors(33, :);
                    groundtruth(curlabel) = 33;
                case 'suit_rb'
                    curcolor = colors(34, :);
                    groundtruth(curlabel) = 34;
                case 'sunglasses_rb'
                    curcolor = colors(35, :);
                    groundtruth(curlabel) = 35;
                case 'sweater_rb'
                    curcolor = colors(36, :);
                    groundtruth(curlabel) = 36;
                case 'sweatshirt_rb'
                    curcolor = colors(37, :);
                    groundtruth(curlabel) = 37;
                case 'tshirt_rb'
                    curcolor = colors(38, :);
                    groundtruth(curlabel) = 38;
                case 'tie_rb'
                    curcolor = colors(39, :);
                    groundtruth(curlabel) = 39;
                case 'tights_rb'
                    curcolor = colors(40, :);
                    groundtruth(curlabel) = 40;
                case 'top_rb'
                    curcolor = colors(41, :);
                    groundtruth(curlabel) = 41;
                case 'vest_rb'
                    curcolor = colors(42, :);
                    groundtruth(curlabel) = 42;
                case 'wallet_rb'
                    curcolor = colors(43, :);
                    groundtruth(curlabel) = 43;
                case 'boots_rb'
                    curcolor = colors(44, :);
                    groundtruth(curlabel) = 44;
                case 'clogs_rb'
                    curcolor = colors(45, :);
                    groundtruth(curlabel) = 45;
                case 'earrings_rb'
                    curcolor = colors(46, :);
                    groundtruth(curlabel) = 46;
                case 'flats_rb'
                    curcolor = colors(47, :);
                    groundtruth(curlabel) = 47;
                case 'heels_rb'
                    curcolor = colors(48, :);
                    groundtruth(curlabel) = 48;
                case 'hoodie_rb'
                    curcolor = colors(49, :);
                    groundtruth(curlabel) = 49;
                case 'loafers_rb'
                    curcolor = colors(50, :);
                    groundtruth(curlabel) = 50;
                case 'panties_rb'
                    curcolor = colors(51, :);
                    groundtruth(curlabel) = 51;
                case 'pumps_rb'
                    curcolor = colors(52, :);
                    groundtruth(curlabel) = 52;
                case 'sandals_rb'
                    curcolor = colors(53, :);
                    groundtruth(curlabel) = 53;
                case 'sneakers_rb'
                    curcolor = colors(54, :);
                    groundtruth(curlabel) = 54;
                case 'swimwear_rb'
                    curcolor = colors(55, :);
                    groundtruth(curlabel) = 55;
                case 'watch_rb'
                    curcolor = colors(56, :);
                    groundtruth(curlabel) = 56;
                case 'wedges_rb'
                    curcolor = colors(57, :);
                    groundtruth(curlabel) = 57;
            end
            [rows cols] = find(labelmap == curlabel);
            for i=1:length(rows)
                I(rows(i), cols(i), 1) = curcolor(1);
                I(rows(i), cols(i), 2) = curcolor(2);
                I(rows(i), cols(i), 3) = curcolor(3);
            end

            axes(handles.image);

            hImg = imshow(I,[]);
            set(hImg,'ButtonDownFcn',{@ImgButtonDown,handles, im, labelmap, I});
            set(handles.output, 'WindowButtonMotionFcn', {@ImgButtonMotion, handles, im, labelmap, I});
            lastlabel = curlabel;
        end
    end
end




% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on selection change in imgmenu.
function imgmenu_Callback(hObject, eventdata, handles)
% hObject    handle to imgmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imgmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imgmenu


% --- Executes during object creation, after setting all properties.
function imgmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imgmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% global var
global imlist;
imlist = dir('selected_full/*.jpg');
imarray = [1:length(imlist)];
set(hObject, 'string', imarray);


% --- Executes on mouse press over axes background.
function image_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function image_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate image

global isdraw;
global lastlabel colors
global ids clothings
load('data/ids53');
load('data/clothings.mat');
isdraw = false;
lastlabel = 0;
% 
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
% colors = uint8(colors*255);
colors = colormap(jet(57));
colors = uint8(colors*255);
global shoes
shoes = [
    40, %     sneakers
    36, %     shoes
    29, %     pumps
    33, %     sandals
    8,  %     boots
    21, %     heels
    13, %     clogs
    16, %     flats
    26, %     loafers
    53 %     wedges
];


% --- Executes on button press in nextbtn.
function nextbtn_Callback(hObject, eventdata, handles)
% hObject    handle to nextbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global colors curnum groundtruth name tagIDs
curnum = curnum+1;
set(handles.imgmenu,'Value', curnum);


load(['selected_ucm/' name '_ucm2.mat'], 'ucm2');
[labelmap edgemap] = get_ucm_sp(ucm2, 0.03);

% imgt = visgt(colors, labelmap, groundtruth);
save(['pixel-level/' name '.mat'], 'groundtruth');

imgt = demo(name);
imwrite(imgt, ['gtvis/' name '.png']);

Label = unique(groundtruth);
save(['image-level/', name, '.mat'], 'Label');



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over nextbtn.
function nextbtn_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to nextbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in btnGroup.
function btnGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in btnGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function tagbtn_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in tagbtn.
function tagbtn_Callback(hObject, eventdata, handles)
% hObject    handle to tagbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tagIDs shoes
newTagID = 1;
load('data/clothings.mat');

switch get(get(handles.btnGroup,'SelectedObject'),'Tag')
    case 'accessories_rb'
        newTagID = 2;
    case 'bag_rb'
        newTagID = 3;
    case 'belt_rb'
        newTagID = 4;
    case 'blazer_rb'
        newTagID = 5;
    case 'blouse_rb'
        newTagID = 6;
    case 'bodysuit_rb'
        newTagID = 7;
    case 'brassiere_rb'
        newTagID = 9;
    case 'bracelet_rb'
        newTagID = 10;
    case 'cape_rb'
        newTagID = 11;
    case 'cardigan_rb'
        newTagID = 12;
    case 'coat_rb'
        newTagID = 14;
    case 'dress_rb'
        newTagID = 15;
    case 'glasses_rb'
        newTagID = 18;
    case 'gloves_rb'
        newTagID = 19;
    case 'hair_rb'
        newTagID = 20;
    case 'hat_rb'
        newTagID = 21;
    case 'jacket_rb'
        newTagID = 25;
    case 'jeans_rb'
        newTagID = 26;
    case 'jumper_rb'
        newTagID = 27;
    case 'leggings_rb'
        newTagID = 28;
    case 'necklace_rb'
        newTagID = 30;
    case 'pants_rb'
        newTagID = 32;
    case 'purse_rb'
        newTagID = 34;
    case 'ring_rb'
        newTagID = 35;
    case 'romper_rb'
        newTagID = 36;
    case 'scarf_rb'
        newTagID = 38;
    case 'shirt_rb'
        newTagID = 39;
    case 'shoes_rb'
        newTagID = 40;
    case 'shorts_rb'
        newTagID = 41;
    case 'skin_rb'
        newTagID = 42;
    case 'skirt_rb'
        newTagID = 43;
    case 'socks_rb'
        newTagID = 45;
    case 'stockings_rb'
        newTagID = 46;
    case 'suit_rb'
        newTagID = 47;
    case 'sunglasses_rb'
        newTagID = 48;
    case 'sweater_rb'
        newTagID = 49;
    case 'sweatshirt_rb'
        newTagID = 50;
    case 'tshirt_rb'
        newTagID = 52;
    case 'tie_rb'
        newTagID = 53;
    case 'tights_rb'
        newTagID = 54;
    case 'top_rb'
        newTagID = 55;
    case 'vest_rb'
        newTagID = 56;
    case 'wallet_rb'
        newTagID = 57;
end

newTagID = clothings{1}(newTagID);
if newTagID == 0 && ~isempty(tagIDs)
    tagIDs = tagIDs(1 : length(tagIDs) - 1);
elseif isempty(find(tagIDs == newTagID, 1))
    tagIDs = [tagIDs, newTagID];
end
tags = [];
for i = 1 : length(tagIDs)
    if ~isempty(find(shoes == single_labelmapping(true, tagIDs(i)), 1))
        tagName = 'shoes';
    else
        tagName = get_tag_name(tagIDs(i), clothings);
    end
    tags = [tags, tagName, ' | '];
end
tags = tags(1 : length(tags) - 3);

set(handles.tagtext, 'string', tags);


% --- Executes during object deletion, before destroying properties.
function tagbtn_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to tagbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_btn.
function save_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% imgt = visgt(colors, labelmap, groundtruth);
global groundtruth name
save(['pixel-level/' name '.mat'], 'groundtruth');

% imwrite(imgt, ['gtvis/' name '.png']);

Label = unique(groundtruth);
save(['image-level/', name, '.mat'], 'Label');


% --- Executes on button press in save_show_btn.
function save_show_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_show_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global groundtruth name
save(['pixel-level/' name '.mat'], 'groundtruth');

imgt = demo(name);
imwrite(imgt, ['gtvis/' name '.png']);

Label = unique(groundtruth);
save(['image-level/', name, '.mat'], 'Label');
