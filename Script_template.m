% Boyang Hu
% ssybh2@nottingham.edu.cn

%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]

% Establish communication between MATLAB and Arduino
a = arduino("COM3","Uno");

% Blink one LED at 0.5 s intervals
for i = 1:10
    writeDigitalPin(a,"D8",1);
    pause(0.5);
    writeDigitalPin(a,"D8",0);
    pause(0.5);
end

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

% Insert answers here

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% Insert answers here


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

% Insert answers here


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here