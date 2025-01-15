%vid = videoinput('winvideo',2);  % Adjust 'winvideo' and 2 as needed
%vid.FramesPerTrigger = Inf;  % Acquires frames continuously
%vid.ReturnedColorspace = 'rgb';
%start(vid);



% Set parameters for the PCB field
SF = 7;                % Scaling factor for viewability
YTRACES = 114;         % Number of horizontal traces on PCB
XTRACES = 118;         % Number of vertical traces on PCB
WIDTH = XTRACES * SF;  % Number of vertical traces on the field
HEIGHT = YTRACES * SF; % Number of horizontal traces on the field
MAGSIZE = 3 * SF;      % Magnet size (3 traces wide/tall)
RUN = true;            % Enables/disables visualization for debugging
kernel = strel('square', 3);  % 3x3 kernel for noise removal

% Capture a frame from the live video feed
%hImage = image(zeros(vid.VideoResolution(2), vid.VideoResolution(1), 3), 'CDataMapping', 'scaled');
%preview(vid);
%pause(10);

% Start video acquisition
%{
% add this in a try catch probably 
while islogging(vid)
    orig_image = getsnapshot(vid);  % Capture the frame
    imshow(orig_image);
    
    if strcmp(keypress, 'Space')
        % Frame captured, break the loop
        close;
        break;
    elseif strcmp(keypress, 'C')
        % Exit without capturing
        close;
        stop(vid)
        delete(vid)
        clear vid;
        return;
    end
end 
%}
%%% Section
vid = VideoReader('P_sample_video.mp4');
vid.CurrentTime = 3; % 1 second
orig_image = readFrame(vid);
if RUN
    imshow(orig_image);
    pause(1);
end

% Convert image to HSV and apply color masks for orange PCB and yellow stiffener
imageHSV = rgb2hsv(orig_image);
low_orange_thresh = [22/360, 120/255, 85/255];
high_orange_thresh = [37/360, 1, 1];
low_yellow_thresh = [37/360, 75/255, 90/255];
high_yellow_thresh = [50/360, 170/255, 200/255];
masked_orange = (imageHSV(:,:,1) >= low_orange_thresh(1) & imageHSV(:,:,1) <= high_orange_thresh(1)) & ...
                (imageHSV(:,:,2) >= low_orange_thresh(2) & imageHSV(:,:,2) <= high_orange_thresh(2)) & ...
                (imageHSV(:,:,3) >= low_orange_thresh(3) & imageHSV(:,:,3) <= high_orange_thresh(3));

masked_yellow = (imageHSV(:,:,1) >= low_yellow_thresh(1) & imageHSV(:,:,1) <= high_yellow_thresh(1)) & ...
                (imageHSV(:,:,2) >= low_yellow_thresh(2) & imageHSV(:,:,2) <= high_yellow_thresh(2)) & ...
                (imageHSV(:,:,3) >= low_yellow_thresh(3) & imageHSV(:,:,3) <= high_yellow_thresh(3));

% Morphological operations to remove noise
masked_orange = imdilate(masked_orange, kernel);
masked_orange = imdilate(masked_orange, kernel);
masked_orange = imerode(masked_orange, kernel);
masked_orange = imerode(masked_orange, kernel);
if RUN
    imshow(masked_orange);
    pause(1)
end

masked_yellow = imdilate(masked_yellow, kernel);
masked_yellow = imdilate(masked_yellow, kernel);
masked_yellow = imdilate(masked_yellow, kernel);
masked_yellow = imerode(masked_yellow, kernel);
masked_yellow = imerode(masked_yellow, kernel);
masked_yellow = imerode(masked_yellow, kernel);
if RUN
    imshow(masked_yellow);
    pause(1)
end

% Combine the two masks, ensuring the stiffener is "turned off"
masked_yellow = ~masked_yellow;
masked_final = masked_orange & masked_yellow;
if RUN
    imshow(masked_final);
    pause(1)
end

labeledImage = bwlabel(masked_final);
props = regionprops(labeledImage, 'ConvexArea', 'ConvexHull');
allAreas = [props.ConvexArea];
[~, largestAreaIndex] = max(allAreas);


contours = props(largestAreaIndex).ConvexHull;
field = reducepoly(contours, .11);
correctField = images.roi.Polygon(gca,'Position',field);
masked = createMask(correctField, orig_image);

hold on
imshow(masked)

rect = order_points(field);
dst = [0,0; 0, HEIGHT; WIDTH,HEIGHT; WIDTH,0];
M = fitgeotrans(rect, dst, 'projective');
squared = imwarp(orig_image, M, 'OutputView', imref2d([HEIGHT, WIDTH]));
squared_mask = imwarp(masked_final, M, 'OutputView', imref2d([HEIGHT, WIDTH]));
figure;
imshow(squared_mask);

contours = regionprops(bwconncomp(~squared_mask), 'BoundingBox');
for i = 1:length(contours)
    box = contours(i).BoundingBox;
    if abs(box(3) - MAGSIZE) < SF * 1.25 && abs(box(4) - MAGSIZE) < SF * 1.25
        magnet_x = box(1) + box(3)/2;
        magnet_y = box(2) + box(4)/2;
        
        % Draw the magnet contour
        rectangle('Position', box, 'EdgeColor', 'b', 'LineWidth', 2);
        pause(1)
        break;
    end
end

% Generate A* grid and save the map
map = zeros(YTRACES, XTRACES);
for row = 1:YTRACES
    for col = 1:XTRACES
        gridCell = squared_mask((SF * (row-1) + 1):(SF * row), (SF * (col-1) + 1):(SF * col));
        blackPixels = sum(gridCell(:) == 0);
        if blackPixels > 0.5 * SF * SF
            map(row, col) = 1;  % Mark as obstacle
        else
            map(row, col) = 0;
        end
    end
end

% Erode and dilate to add padding around obstacles
map = imerode(map, kernel);
map = imdilate(map, kernel);
map = imdilate(map, kernel);

% Display the A* grid
figure;
imshow(imresize(map, SF));
title('A* Grid');
if ~RUN
    map = map.*-1;
end

% Add magnet location to the grid
magnet_x_idx = floor(magnet_x / SF);
magnet_y_idx = floor(magnet_y / SF);
map(magnet_y_idx, magnet_x_idx) = 1;

%stop(vid)
%delete(vid)
%clear vid

function rect = order_points(pts)
    % Initialize a 4x2 matrix to store the ordered points
    rect = zeros(4, 2);

    % Step 1: Sum of (x + y) coordinates to find top-left and bottom-right points
    s = sum(pts, 2);  % Sum along rows
    [~, minIdx] = min(s);  % Find index of the smallest sum (top-left)
    [~, maxIdx] = max(s);  % Find index of the largest sum (bottom-right)
    
    rect(1, :) = pts(minIdx, :);  % Top-left
    rect(3, :) = pts(maxIdx, :);  % Bottom-right

    % Step 2: Difference of (x - y) coordinates to find top-right and bottom-left points
    diff = pts(:,1)-pts(:,2);  % Compute the difference along the second dimension
    [~, minDiffIdx] = min(diff);  % Top-right point (smallest difference)
    [~, maxDiffIdx] = max(diff);  % Bottom-left point (largest difference)
    
    rect(2, :) = pts(minDiffIdx, :);  % Top-right
    rect(4, :) = pts(maxDiffIdx, :);  % Bottom-left
end