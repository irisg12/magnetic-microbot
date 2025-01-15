% 10/29/24 Version
close all
% Set parameters for the PCB field
SF = 100;                % Scaling factor for viewability                   % changed
YTRACES = 7;         % Number of horizontal traces on PCB
XTRACES = 7;         % Number of vertical traces on PCB
WIDTH = XTRACES * SF;  % Width of the displayed field image
HEIGHT = YTRACES * SF; % Height of the displayed field image
MAGSIZE = .15 * SF;      % Magnet size (2.4 traces wide/tall)              % changed
RUN = true;            % Enables/disables visualization for debugging
vid_bool = false;        % true for video, false for image
kernel = strel('square', 4);  % 3x3 kernel for noise removal

low_orange_thresh = [1/360, 10/255, 95/255];
high_orange_thresh = [350/360, 75/255, 200/255];

low_yellow_thresh = [36/360, 25/255, 85/255];
high_yellow_thresh = [55/360, 150/255, 215/255];

low_blue_thresh = [200/360, 80/255, 30/255];
high_blue_thresh = [260/360, 255/255, 170/255];

% run webcamlist for list of webcams if correct index or name is not found
% requires webcam support package for newer MATLAB versions
if vid_bool
    vid = webcam(2); % 2 is typically the index of the external webcam
end 


%% Live Video 
figure(1);
set(gcf, 'Units', 'normalized', 'Position', [0.02, 0.6, 0.45, 0.3]); % sets screen location
if RUN
    figure(2);
    set(gcf, 'Units', 'normalized', 'Position', [0.3, 0.2, 0.3, 0.7]); % sets screen location
end
while true
    if ~vid_bool                                                            % image code
        orig_image = imread("OliviaImage.png");
    else
        orig_image = snapshot(vid);
    end
    % converts image color format to HSV, then creates three masks:
    % orange holds just the magnet
    % yellow holds the stiffener
    % blue holds the obstacles
    imageHSV = rgb2hsv(orig_image);
    masked_orange = (imageHSV(:,:,1) >= low_orange_thresh(1) & imageHSV(:,:,1) <= high_orange_thresh(1)) & ...
                    (imageHSV(:,:,2) >= low_orange_thresh(2) & imageHSV(:,:,2) <= high_orange_thresh(2)) & ...
                    (imageHSV(:,:,3) >= low_orange_thresh(3) & imageHSV(:,:,3) <= high_orange_thresh(3));
    
    masked_yellow = (imageHSV(:,:,1) >= low_yellow_thresh(1) & imageHSV(:,:,1) <= high_yellow_thresh(1)) & ...
                    (imageHSV(:,:,2) >= low_yellow_thresh(2) & imageHSV(:,:,2) <= high_yellow_thresh(2)) & ...
                    (imageHSV(:,:,3) >= low_yellow_thresh(3) & imageHSV(:,:,3) <= high_yellow_thresh(3));
    
    masked_blue = (imageHSV(:,:,1) >= low_blue_thresh(1) & imageHSV(:,:,1) <= high_blue_thresh(1)) & ...
                    (imageHSV(:,:,2) >= low_blue_thresh(2) & imageHSV(:,:,2) <= high_blue_thresh(2)) & ...
                    (imageHSV(:,:,3) >= low_blue_thresh(3) & imageHSV(:,:,3) <= high_blue_thresh(3));
    
    imopen(masked_yellow, strel('square', 6));
    % dilate and erode image to remove noise
    for i = 1:4
        masked_yellow = imdilate(masked_yellow, kernel);
    end
    for i = 1:4
        masked_yellow = imerode(masked_yellow, kernel);
    end

    masked_field = ~masked_yellow;

    if RUN
        figure(2);
        subplot(3,1,1);
        masked_orange = imdilate(masked_orange, kernel);
        masked_orange = imerode(masked_orange, kernel);
        masked_orange = imerode(masked_orange, kernel);
        masked_orange = imdilate(masked_orange, kernel);
        imshow(masked_orange);
        ylabel("Orange Mask")
        subplot(3,1,2); 
        imshow(masked_yellow);
        ylabel("Yellow Mask")
        subplot(3,1,3);
        imshow(masked_blue);
        ylabel("Blue Mask")
        figure(1);
    end

    % converts the mask to binary and identifies the largest regions
    labeledImage = logical(masked_field);
    props = regionprops(labeledImage, 'ConvexArea', 'ConvexHull');
    allAreas = [props.ConvexArea];
    % sorts so the largest regions are first
    [~, sortedAreas] = sort(allAreas, 'descend');
    % if no regions are found, does not throw an error
    if length(allAreas) < 1 && vid_bool
        continue;
    end

    % selects the second largest contour (inside border of the stiffener) and approximates it
    contours = props(sortedAreas(2)).ConvexHull;
    field = reducepoly(contours, .05);
    % shows the frame
    imshow(orig_image);
    hold on;
    % Converts to a polygon object for convenient processing
    % displays this on the frame
    correctField = images.roi.Polygon(gca,'Position',field);
    masked = createMask(correctField, orig_image);
    hold off;
    pause(0.15); % frame rate

    % Press 'space' to save the current frame
    if (strcmp(get(gcf, 'CurrentKey'), 'space') || ~vid_bool)                 % image code
        % smooths out obstacle shapes
        masked_blue = imdilate(masked_blue, strel('square', 12));
        masked_blue = imerode(masked_blue, strel('square', 12));
        % removes noise/regions that are too small
        masked_blue = imerode(masked_blue, strel('square', 12));
        masked_blue = imdilate(masked_blue, strel('square', 12));

        masked_orange = imdilate(masked_orange, kernel);
        masked_orange = imerode(masked_orange, kernel);
        masked_orange = imerode(masked_orange, kernel);
        masked_orange = imdilate(masked_orange, kernel);

        masked_magnet = masked_orange; 
        masked_obstacles = masked_blue;
        break;
    end
     % Press 'c' to exit program
    if strcmp(get(gcf, 'CurrentKey'), 'c')
        return;
    end
end
%% Frame Processing
% transforms masked and original quadrilaterals to 114 x 118 proper rectangle
rect = order_points(field); % 4 points of the field in order CW
dst = [0,0; 0, HEIGHT; WIDTH,HEIGHT; WIDTH,0]; % desired points in order CW
M = fitgeotrans(rect, dst, 'projective');
% transforms the image, the obstacle mask, and the magnet mask
squared = imwarp(orig_image, M, 'OutputView', imref2d([HEIGHT, WIDTH]));
squared_mask = imwarp(masked_obstacles, M, 'OutputView', imref2d([HEIGHT, WIDTH]));
squared_magnet = imwarp(masked_magnet, M, 'OutputView', imref2d([HEIGHT, WIDTH]));
if RUN
   figure;
   imshow(squared_mask);
   pause(1)
end

% creates a bounding box for each contour in order to find the magnet sized
% one; searching through the largest contours first
magnet_x = -1;
magnet_y = -1;
contours = regionprops(bwconncomp(squared_magnet), 'BoundingBox', 'ConvexArea');
magAreas = [contours.ConvexArea];
[~, sortedmagAreas] = sort(magAreas, 'descend');
for i = 1:length(contours)
    box = contours(sortedmagAreas(i)).BoundingBox;
    % due to masking, magnet typically ends up as around an 11x14 sized region
    if abs(box(3) - MAGSIZE) < 6.5 && abs(box(4) - MAGSIZE) < 6.5
        magnet_x = box(1) + box(3)/2;
        magnet_y = box(2) + box(4)/2;
        
        % Draw the magnet contour on the mask
        if RUN
            rectangle('Position', box, 'EdgeColor', 'r', 'LineWidth', 2);
            pause(1)
        end
        break;
    end
end

%% Map Making
% load the 114 x 118 grid that will be used for
% A* pathfinding with obstacles and magnet
map = zeros(YTRACES, XTRACES);
for row = 1:YTRACES
    for col = 1:XTRACES
        gridCell = squared_mask((SF * (row-1) + 1):(SF * row), (SF * (col-1) + 1):(SF * col));
        blackPixels = sum(gridCell(:) == 0);
        % If >50% of the pixels in that grid section are black, 
        % the A* square will be categorized as an obstacle (-1)
        if blackPixels > 0.5 * SF * SF
            map(row, col) = 0;  
        else
            map(row, col) = 1; % Mark as obstacle
        end
    end
end
                                                                            % changed
% # cleans up map noise and adds padding around each obstacle
% to prevent the magnet from touching them
% NO EROSION NEEDED ON 7x7: will delete obstacles
%map = imerode(map, kernel);
%map = imdilate(map, kernel);
%map = imdilate(map, kernel);

magnet_x_idx = floor(magnet_x / SF)+1;
magnet_y_idx = floor(magnet_y / SF)+1;

% Add magnet location to the grid
if (magnet_x > 0)
    map(magnet_y_idx, magnet_x_idx) = 1;
end

% Display the A* grid
if RUN
    if (magnet_x > 0)
        map(magnet_y_idx, magnet_x_idx) = .5;
    end
    imshow(imresize(map, SF, 'nearest'));
    title('A* Grid');
end

map = map.*-1; % obstacles are -1

clear vid

function rect = order_points(pts)
    % Initialize a 4x2 matrix to store the ordered points
    rect = zeros(4, 2);

    % top left will have the smallest sum, whereas
    % bottom-right will have the largest sum
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
