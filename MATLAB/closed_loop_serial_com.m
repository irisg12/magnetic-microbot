% 11/18/24 Version
% Using a live video feed, user selects starting and ending points for the
% mmbot. Sends the Arduino serial communication directions to move autonomously 
% to target using template matching and closed loop control.

close all;
clear;

% pins should be in top right corner of board
SF = 8;                % Scaling factor for viewability
YTRACES = 114;         % Number of horizontal traces on PCB
XTRACES = 118;         % Number of vertical traces on PCB
WIDTH = XTRACES * SF;  % Width of the displayed field image
HEIGHT = YTRACES * SF; % Height of the displayed field image
MAGSIZE = 2.4 * SF;    % Magnet size (2.4 traces wide/tall)
ARD_ON = 1;            % turns arduino code on/off for checking functionality of MATLAB code only
FRAMERATE = .075;      % seconds between frames
THRESH = 3;            % threshold distance from the target in traces (114x118)

vid = webcam(2);       % adjust parameter based off webcamlist
tempSize = round(MAGSIZE/2*2); % 1/2 the width of the template size
iSize = tempSize*3;              % 1/2 the width of the I search area

if ARD_ON == 1
    serialPort = "COM7"; % must change depending on the port
    baudRate = 9600;
    arduino1 = serialport(serialPort, baudRate);
    configureTerminator(arduino1, "LF");
    flush(arduino1); % Clear the serial port buffer
    write(arduino1, 'X', 'char')
end

% mmbot_video_processing;

% allows users to click the four corners of the field to find the
% transformation matrix
M = getField(vid, WIDTH, HEIGHT);
frame = imwarp(snapshot(vid), M, 'OutputView', imref2d([HEIGHT, WIDTH]));

% opens the cropped field picture to display the path
figure;
while true
    squared = imshow(frame);
    hold on;
    % Allows user to select the start and end points 
    xlabel(sprintf(['Select the magnet using the Left Mouse button. ' ...
        '\n Select outside the image to terminate.']),'Color','black');
    but=0;
    while (but ~= 1) 
        [xval,yval,but]=ginput(1);
    end
    if xval < .5 || xval > WIDTH || yval < .5 || yval > HEIGHT
        break;
    end
    xval=floor(xval/SF)+1;
    yval=floor(yval/SF)+1;
    xStart=xval; % X Coordinate of the starting point in traces (0-118)
    yStart=yval; % Y Coordinate of the starting point in traces (0-114)
    plot((xStart-.5)*SF, (yStart-.5)*SF, "g*"); % pass scale factor

    xlabel('Select the Target using the Left Mouse button','Color','black');
    but=0;
    while (but ~= 1) % Repeat until the Left button is not clicked
        [xval,yval,but]=ginput(1);
        if xval < .5 || xval > WIDTH || yval < .5 || yval > HEIGHT
            but =0;
        end
    end
    xval=floor(xval/SF)+1;
    yval=floor(yval/SF)+1;
    xTarget=xval;% X Coordinate of the Target in traces (0-118)
    yTarget=yval;% Y Coordinate of the Target in traces (0-114)
    plot((xTarget-.5)*SF, (yTarget-.5)*SF, "ro"); % pass scale factor
    xlabel('');
    
    LR = xTarget-xStart; % horizontal distance from start to target
    UD = yTarget-yStart; % vertical distance from start to target
    xNew = xStart;       % current magnet x coordinate in traces (0-118)
    yNew = yStart;       % current magnet y coordinate in traces (0-114)
    
    frame = snapshot(vid);
    frame = imwarp(frame, M, 'OutputView', imref2d([HEIGHT, WIDTH]));
    squared.CData = frame;
    
    % defines the template
    topY = max((yNew-.5)*SF-tempSize, 1);
    bottomY = min((yNew-.5)*SF+tempSize, HEIGHT);
    leftX = max((xNew-.5)*SF-tempSize, 1);
    rightX = min((xNew-.5)*SF+tempSize, WIDTH);
    T = frame(topY:bottomY, leftX:rightX, 1:3);
    
    while ((abs(LR) >= THRESH) || (abs(UD) >= THRESH))
        if ((abs(LR) >= THRESH) && (abs(UD) >= THRESH))
            % move diagonally
            if (LR <= 0 && UD <= 0)
                dir = 'A';
            elseif (LR >= 0 && UD <= 0)
                dir = 'B';
            elseif (LR >= 0 && UD >= 0)
                dir = 'C';
            elseif (LR <= 0 && UD >= 0)
                dir = 'D';
            end
        else 
            if (abs(LR) <= THRESH && UD < 0)
                dir = 'N';
            elseif (abs(LR) <= THRESH && UD > 0)
                dir = 'S';
            elseif (LR < 0 && abs(UD) <= THRESH)
                dir = 'W';
            elseif (LR > 0 && abs(UD) <= THRESH)
                dir = 'E';
            end
        end
        disp(dir)
        if ARD_ON
            write(arduino1, dir, 'char');
            write(arduino1, dir, 'char');
            flush(arduino1);
        end
    
        pause(FRAMERATE);
            
        % grabs image of the magnet after it has moved
        frame = snapshot(vid);
        frame = imwarp(frame, M, 'OutputView', imref2d([HEIGHT, WIDTH]));
        squared.CData = frame;
        % defines the area I to be searched
        topY = max(yNew*SF-iSize, 1);
        bottomY = min(yNew*SF+iSize, HEIGHT);
        leftX = max(xNew*SF-iSize, 1);
        rightX = min(xNew*SF+iSize, WIDTH);
        I = frame(topY:bottomY, leftX:rightX, 1:3);
    
        % template matching
        [I_SSD,I_NCC]=template_matching(T,I);
        % Extract position based on SSD metric
        [trajY,trajX]=find(I_NCC==max(I_NCC(:))); % new magnet coordinates local to I
    
        % calculates the new coordinates and plots them
        xNew = floor((leftX + trajX - 1)/SF)+1; 
        yNew = floor((topY + trajY - 1)/SF)+1; 
        plot((xNew-.5)*SF, (yNew-.5)*SF, "go")

        % creates new template 
        topY = max(trajY-tempSize, 1);
        bottomY = min(trajY+tempSize, iSize*2 + 1);
        leftX = max(trajX-tempSize, 1);
        rightX = min(trajX+tempSize, iSize*2 + 1);
        T = I(topY:bottomY, leftX:rightX, 1:3);
        %figure(2);
        %imshow(T);
        %figure(1);
    
        % finds the new distances from the target
        LR = xTarget-xNew;
        UD = yTarget-yNew;
    end
    xlabel("Target reached")
    write(arduino1, 'X', 'char');
    flush(arduino1);
    pause(1);
end

% target reached
if ARD_ON == 1 
    write(arduino1, 'F', 'char');
    flush(arduino1);
    pause(2);
    % Read "target reached" response from the Arduino
    data = readline(arduino1); 
    disp(data)
    xlabel("Program Terminated");
    
    % Clean up
    clear arduino1;
end

function M = getField(vid, WIDTH, HEIGHT) 
    pause(.5);
    orig_image = snapshot(vid);
    imshow(imresize(orig_image, 2));
    xlabel('Select the field corners starting from the top left going CCW.','Color','black');
    but=0;
    while (but ~= 1) % Repeat until the Left button is not clicked
        [xval,yval,but]=ginput(4);
    end
    % something to indicate points clicked? 

    dst = [0,0; 0, HEIGHT; WIDTH,HEIGHT; WIDTH,0]; % desired points in order CW
    M = fitgeotrans([xval/2,yval/2], dst, 'projective');
    disp(M);
    close(1)
end
