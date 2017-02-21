function [ T ] = getAWSList( path )
if exist([path '\list'])==2;
        T = readtable('list'); % read scene_list
    T.processingLevel = []; T.min_lat = []; T.min_lon = [] ;T.max_lon = []; T.max_lat = [];
    cclimit = 70; %delete cloud cover bigger than 70
    index1 = T.cloudCover>cclimit;
    T(index1,:) = [];
    
else
    urlwrite('http://landsat-pds.s3.amazonaws.com/scene_list.gz','list.gz');
    gunzip('*.gz');
    T = readtable('list'); % read scene_list
    T.processingLevel = []; T.min_lat = []; T.min_lon = [] ;T.max_lon = []; T.max_lat = [];
    cclimit = 70; %delete cloud cover bigger than 70
    index1 = T.cloudCover>cclimit;
    T(index1,:) = [];
end
end

