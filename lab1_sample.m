%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Define the serial port and baud rate 
    % use "serialportlist" command to see list of available com ports 
    % Windows machines names will appear as "COM3", "COM4", etc. 
    % Mac/OS machine names will appear as "/dev/tty.usbmodem1101" 
 
ARD_ON = 1; % turns arduino code on/off for checking functionality of MATLAB code only 
if ARD_ON == 1 
    serialPort = "COM10"; % must change depending on the port  
    baudRate = 9600; 
    arduino1 = serialport(serialPort, baudRate); 
    configureTerminator(arduino1, "LF"); 
    flush(arduino1); % Clear the serial port buffer 
end 
 
%% 
Ndir = 'N'; % North 
Sdir = 'S'; % South 
Wdir = 'W'; % West 
Edir = 'E'; % East 
Adir = 'A'; % NW | Diagonal 
Bdir = 'B'; % NE | Diagonal 
Cdir = 'C'; % SE | Diagonal 
Ddir = 'D'; % SW | Diagonal 
 
%% 
if ARD_ON == 1 
    for i = 1:20 
        write(arduino1, Ndir, 'char'); % Send the character to move North direction 
        flush(arduino1);
        pause(.1)  % pause 1 second between each step 
    end 
    for i = 1:20 
        write(arduino1, Wdir, 'char'); % Send the character to move North direction 
        flush(arduino1);
        pause(.1)  % pause 1 second between each step 
    end
    for i = 1:20 
        write(arduino1, Sdir, 'char'); % Send the character to move North direction 
        flush(arduino1);
        pause(.1)  % pause 1 second between each step 
    end
    for i = 1:20 
        write(arduino1, Edir, 'char'); % Send the character to move North direction 
        flush(arduino1);
        pause(.1)  % pause 1 second between each step 
    end
    for i = 1:20 
        write(arduino1, Adir, 'char'); % Send the character to move North direction 
        flush(arduino1);
        pause(.1)  % pause 1 second between each step 
    end 
end 
write(arduino1,'F', 'char');
flush(arduino1);
 
fprintf("done\n")
% Clean up 
flush(arduino1);      % clear serial port buffer 
ARD_ON = 0;           % turn arduino code off 
clear arduino1;       % clear serial port stream 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 