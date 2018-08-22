% Anna Underhill
% Cluster Compactness Components
% A program to analyze segmented images of grape clusters

%Set working directory; update with your filepath
cd 'C:\Users\Anna\Documents\School\Graduate School\UMN\GE1025 2017 Segment Local'

%Attempt to individually load files
imagefiles = dir('*.png');%only read in .png files
filenames = {imagefiles.name};
nfiles = length(imagefiles);% Number of files found
h = waitbar(0,'Iterating through images');

%Set up arrays for appending loop output
clusterarea_append_array = {};
clusterpercent_append_array = {};
rachispercent_append_array = {};
spacepercent_append_array = {};
perim_append_array = {};
axislength_append_array = {};
perpendicularWidth25_append_array = {};
perpendicularWidth50_append_array = {};
perpendicularWidth75_append_array = {};
maxlength_append_array = {};
maxwidth_append_array = {};

for ii=1:nfiles
   currentfilename = imagefiles(ii).name;
   currentimage = imread(currentfilename);
   images= currentimage; 
 
%Read in RGB image
rgbImage = currentimage;

% Get the dimensions of the image; numberOfColorBands should be = 3.
[rows, columns, numberOfColorBands] = size(rgbImage);

%Seperate image into color channels
redChannel = rgbImage(:, :, 1);
greenChannel = rgbImage(:, :, 2);
blueChannel = rgbImage(:, :, 3);

%Median filter each channel seperately
redMF = medfilt2(redChannel, [1 1]);
greenMF = medfilt2(greenChannel, [1 1]);
blueMF = medfilt2(blueChannel, [1 1]);

%Recombine channels into final filtered image
rgbFixed = cat(3, redMF, greenMF, blueMF);

%Segment into grapes and rachis
%Create indexed image
[indexedRGB, mapRGB] = rgb2ind(rgbFixed, 3);

%Segment berries and rachis
red = roicolor(indexedRGB, 1, 1);
green = roicolor(indexedRGB, 2, 2);

%Segment background; output is BW
% Convert RGB image into L*a*b* color space
RGB = rgbFixed;
X = rgb2lab(RGB);

% Create empty mask
BW = false(size(X,1),size(X,2));

% Flood fill
row = 1;
column = 1;
tolerance = 5.000000e-02;
normX = sum((X - X(row,column,:)).^2,3);
normX = mat2gray(normX);
addedRegion = grayconnected(normX, row, column, tolerance);
BW = BW | addedRegion;

%Isolate cluster space
%Add everything not cluster space
lessSpace = (red + green + BW);

%Invert so all cluster space selected
space = ~(lessSpace);

%Remove artifacts from masking
space = bwareaopen(space, 2);

%Find areas of each segment
clusterarea = bwarea(red);
rachisarea = bwarea(green);
spacearea = bwarea(space);

%Find percentages of each segment
divisor = (clusterarea + rachisarea + spacearea);
clusterpercent = ((clusterarea ./ divisor) * 100);
rachispercent = ((rachisarea ./ divisor) * 100);
spacepercent = ((spacearea ./ divisor) * 100);

%Find perimeter
cluster = ~(BW);
perim_cluster = bwpropfilt(cluster,'perimeter',1); %Eliminates all but largest perimeter
P = regionprops(perim_cluster,'perimeter');
perim = P.Perimeter;

%Find upper- and lowermost pixels in cluster
rotated = imrotate(cluster, 90);
rotated = bwareaopen(rotated, 20); %remove small disconnected blobs; (image, pixel # threshold)
[row, column] = find(rotated, 1, 'first'); 
topX = column;
topY = row;
[row, column] = find(rotated, 1, 'last');
bottomX = column;
bottomY = row;
X = [topX, bottomX];
Y = [topY, bottomY];
axislength = pdist2(X, Y,'euclidean');

%Find bounding box for max length/width
bounds = regionprops(rotated, 'BoundingBox');
boundingLeft = (bounds(1).BoundingBox(1)-0.5);
boundingTop = (bounds(1).BoundingBox(2)-0.5);
maxLength = bounds(1).BoundingBox(3);
maxWidth = bounds(1).BoundingBox(4);

%Find 25% and 75% axis points
n = 2;
deltax = (bottomX - topX)./n;
deltay = (bottomY - topY)./n;
halfdx = deltax./2;
halfdy = deltay./2;
xcents = topX + halfdx + (0:n-1).*deltax; %Array with 2 x-coords [25x, 75x]
ycents = topY + halfdy + (0:n-1).*deltay; %Array with 2 y-coords [25y, 75y]

%Plot the boundary
boundaries = bwboundaries(rotated);
numberOfBoundaries = size(boundaries, 1);
for clusterIndex = 1 : numberOfBoundaries
	thisBoundary = boundaries{clusterIndex};
	x = thisBoundary(:, 2); % x = columns
	y = thisBoundary(:, 1); % y = rows
end
	
	% Find the midpoints of the line.
	xMidPoint = mean([bottomX, topX]);
	yMidPoint = mean([bottomY, topY]); 
    x25 = xcents(1);
    y25 = ycents(1);
    x75 = xcents(2);
    y75 = ycents(2);
	longSlope = (topY - bottomY) / (topX - bottomX);

if longSlope == 0
    y1 = boundingTop;
    y2 = (boundingTop + maxWidth);
    ycross = [y1, y2];
    x25cross = [x25 , x25];
    x50cross = [xMidPoint, xMidPoint];
    x75cross = [x75 , x75]; 

    [cx25,cy25,c25] = improfile(rotated, x25cross, ycross, 25000);
    [cx,cy,c] = improfile(rotated, x50cross, ycross, 25000);
    [cx75,cy75,c75] = improfile(rotated, x75cross, ycross, 25000);
    
    c(isnan(c)) = 0;
    c25(isnan(c25)) = 0;
    c75(isnan(c75)) = 0;
    
    %Find first and last points on the cluster at axes
    firstIndex50 = find(c, 1, 'first');
	lastIndex50 = find(c, 1, 'last');
    firstIndex25 = find(c25, 1, 'first');
	lastIndex25 = find(c25, 1, 'last');
    firstIndex75 = find(c75, 1, 'first');
	lastIndex75 = find(c75, 1, 'last');
    
	% Compute the distance of that perpendicular width
	perpendicularWidth50 = sqrt((cx(firstIndex50)-cx(lastIndex50)).^ 2 +(cy(firstIndex50)-cy(lastIndex50)).^ 2);
    perpendicularWidth25 = sqrt((cx25(firstIndex25)-cx25(lastIndex25)).^ 2 +(cy25(firstIndex25)-cy25(lastIndex25)).^ 2);
    perpendicularWidth75 = sqrt((cx75(firstIndex75)-cx75(lastIndex75)).^ 2 +(cy75(firstIndex75)-cy75(lastIndex75)).^ 2);

else
    
    perpendicularSlope = -1/longSlope;
	% Use point slope formula (y-ym) = slope * (x - xm) to get points
	y1 = perpendicularSlope * (1 - xMidPoint) + yMidPoint;
	y2 = perpendicularSlope * (columns - xMidPoint) + yMidPoint;
    y251 = perpendicularSlope * (1 - x25) + y25;
    y252 = perpendicularSlope * (columns - x25) + y25;
    y751 = perpendicularSlope * (1 - x75) + y75;
    y752 = perpendicularSlope * (columns - x75) + y75;
   
	%Find points where line first enters and last leaves the cluster
	[cx,cy,c] = improfile(rotated,[1, columns], [y1, y2], 25000); 
    [cx25,cy25,c25] = improfile(rotated,[1, columns], [y251, y252], 25000);
    [cx75,cy75,c75] = improfile(rotated,[1, columns], [y751, y752], 25000); 
    
	% Get rid of NAN's that occur when the line's endpoints go above or below the image
	c(isnan(c)) = 0; 
    c25(isnan(c25)) = 0;
    c75(isnan(c75)) = 0;
    
    %Find first and last points on the cluster at axes
    firstIndex50 = find(c, 1, 'first');
	lastIndex50 = find(c, 1, 'last');
    firstIndex25 = find(c25, 1, 'first');
	lastIndex25 = find(c25, 1, 'last');
    firstIndex75 = find(c75, 1, 'first');
	lastIndex75 = find(c75, 1, 'last');
    
	% Compute the distance of that perpendicular width
	perpendicularWidth50 = sqrt((cx(firstIndex50)-cx(lastIndex50)).^ 2 +(cy(firstIndex50)-cy(lastIndex50)).^ 2);
    perpendicularWidth25 = sqrt((cx25(firstIndex25)-cx25(lastIndex25)).^ 2 +(cy25(firstIndex25)-cy25(lastIndex25)).^ 2);
    perpendicularWidth75 = sqrt((cx75(firstIndex75)-cx75(lastIndex75)).^ 2 +(cy75(firstIndex75)-cy75(lastIndex75)).^ 2);
    
end
    
   %Append info for each file to array
   clusterarea_append_array = [clusterarea_append_array;(num2cell(divisor))];
   clusterpercent_append_array = [clusterpercent_append_array;(num2cell(clusterpercent))];
   rachispercent_append_array = [rachispercent_append_array;(num2cell(rachispercent))];
   spacepercent_append_array = [spacepercent_append_array;(num2cell(spacepercent))];
   perim_append_array = [perim_append_array; (num2cell(perim))];
   axislength_append_array = [axislength_append_array;(num2cell(axislength))];
   perpendicularWidth25_append_array = [perpendicularWidth25_append_array;(num2cell(perpendicularWidth25))]; %274 out of 278
   perpendicularWidth50_append_array = [perpendicularWidth50_append_array;(num2cell(perpendicularWidth50))]; %277 out of 278
   perpendicularWidth75_append_array = [perpendicularWidth75_append_array;(num2cell(perpendicularWidth75))]; %275 out of 278
   maxlength_append_array = [maxlength_append_array;(num2cell(maxLength))];
   maxwidth_append_array = [maxwidth_append_array;(num2cell(maxWidth))];
   waitbar(ii/nfiles);
  
end
% Write output to file; change to suit your needs
T = table(clusterarea_append_array, maxlength_append_array, maxwidth_append_array, axislength_append_array, clusterpercent_append_array,rachispercent_append_array,spacepercent_append_array,perim_append_array, perpendicularWidth25_append_array, perpendicularWidth50_append_array, perpendicularWidth75_append_array);
writetable(T,'GE1025_2017_ClusterAnalysis.txt');

% PLOT CODE: Use for visualization of components

	% Plot the boundary over the binary image
% 	imshow(rotated);
%     hold on
% 	plot(x, y, 'y-', 'LineWidth', 3);
% 	% For this blob, put a line between the points farthest away from each other.
% 	line([topX, bottomX], [topY, bottomY], 'Color', 'r', 'LineWidth', 3);
% 	plot(xMidPoint, yMidPoint, 'r*', 'MarkerSize', 15, 'LineWidth', 2);
%     plot(x25, y25, 'g*', 'MarkerSize', 15);
%     plot(x75, y75, 'g*', 'MarkerSize', 15); 
%     rectangle('Position', [bounds(1).BoundingBox(1), bounds(1).BoundingBox(2), bounds(1).BoundingBox(3), bounds(1).BoundingBox(4)], 'EdgeColor','r', 'LineWidth', 3)
% 	% Plot perpendicular line.  Make it green across the whole image but magenta inside the blob.
% 	line([1, columns], [y251, y252], 'Color', 'g', 'LineWidth', 3);	
%     line([1, columns], [y1, y2], 'Color', 'g', 'LineWidth', 3);	
% 	line([1, columns], [y751, y752], 'Color', 'g', 'LineWidth', 3);	
% 	line([cx25(firstIndex25), cx25(lastIndex25)], [cy25(firstIndex25), cy25(lastIndex25)], 'Color', 'm', 'LineWidth', 3);
%     line([cx(firstIndex50), cx(lastIndex50)], [cy(firstIndex50), cy(lastIndex50)], 'Color', 'm', 'LineWidth', 3);
%     line([cx75(firstIndex75), cx75(lastIndex75)], [cy75(firstIndex75), cy75(lastIndex75)], 'Color', 'm', 'LineWidth', 3);