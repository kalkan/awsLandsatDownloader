% Landsat 8 image finder and downloader from map selection
%
% Written by Kaan Kalkan, Istanbul Technical University, 2017
clearvars -except TT
path = pwd;
% initialization
if exist('TT')
    T = TT;
else
    TT = getAWSList(path);
end

% open google maps window
lat = [37 42];
   lon = [25 45];
   plot(lon,lat,'.','MarkerSize',1)
   plot_google_map
   title('Zoom in and press space');

pause; %Pause for zoom in

[selected_lon,selected_lat] = ginput(1); %Coordinates of click
worldmap('turkey');
geoshow('landareas.shp'); %World shape
textm(selected_lat, selected_lon, 'Your Point');
geoshow(selected_lat, selected_lon,...
    'DisplayType', 'point',...
    'Marker', 'o',...
    'MarkerEdgeColor', 'r',...
    'MarkerFaceColor', 'r',...
    'MarkerSize', 3);
%% Find Landsat Scenes
bbox = [selected_lon selected_lat; selected_lon+0.001 selected_lat+0.001];
S = shaperead('wrslandsat/wrs.shp', 'UseGeoCoords', true,'BoundingBox',bbox);
geoshow(S, 'FaceColor', [1 0 0], 'FaceAlpha', .2 );
for i=1:size(S,1);
    ort = mean(S(i).BoundingBox);
    textm(ort(2), ort(1), strrep(S(i).NAME,'_','-'));
    str1{i} = S(i).NAME;
end

pause;
[selection,v] = listdlg('PromptString','Select a scene:',...
    'SelectionMode','single',...
    'ListString',str1);

pathrow = S(selection).NAME;
disp(['you selected ', pathrow]);

close all;
% aws data list
T = TT;
path = str2double(pathrow(1:3)); %delete other path rows
index1 = T.path ~= path;
T(index1,:) = [];
row = str2double(pathrow(5:6)); %delete other path rows
index1 = find(T.row ~= row);
T(index1,:) = [];

% select main image from list of images from aws landsat list for given path-row
T = sortrows(T,2);
T2 = table2cell(T);
for i=1:height(T);
    str2{i} = T2{i,2};
end
[selection,v] = listdlg('PromptString','Select a scene:',...
    'SelectionMode','single','ListSize', [200 400],...
    'ListString',str2);
mainimageid = T{selection,1}{1,1};

% show choosen landsat image thumbnail
imageurl = ['http://landsat-pds.s3.amazonaws.com/L8/', num2str(path), '/', '0', num2str(row), '/', mainimageid];
web([imageurl,'/', 'index.html']);
thumb_url = [imageurl,'/', mainimageid, '_thumb_large.jpg'];
I = imread(thumb_url);
imshow(I);

bands = {'1', '2', '3','4','5','6','7','8','9','10','11'};
[bandList,v] = listdlg('PromptString','Select bands:',...
    'ListString',bands);

numselected = size(bandList,2);
mkdir(['C:\data\', mainimageid]); % open data folder to c disk
disp('Downloading');
winopen('C:\data\');
for i = 1:numselected % download selected bands
    urlwrite([imageurl,'/', mainimageid, '_B', num2str(bandList(i)), '.TIF'],['C:\data\', mainimageid, '\', mainimageid, '_B', num2str(bandList(i)), '.TIF'] );
end

metaFilename = ['C:\data\', mainimageid, '\', mainimageid, 'MTL.txt'];
urlwrite([imageurl,'/', mainimageid, '_MTL.txt'], metaFilename);
mtl = MTLParser(metaFilename);

clearvars -except TT mtl