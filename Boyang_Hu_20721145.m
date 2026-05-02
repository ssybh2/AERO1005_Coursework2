% NAME: Boyang Hu
% Email: ssybh2@nottingham.edu.cn

%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]

% Reuse existing Arduino object if it already exists
if ~exist('a','var')
    a = arduino("COM3","Uno");
    disp('New Arduino connection created on COM3.')
else
    disp('Existing Arduino connection found. Reusing object a.')
end

% LED blink test
% for i = 1:10
%     writeDigitalPin(a,"D8",1);
%     pause(0.5);
%     writeDigitalPin(a,"D8",0);
%     pause(0.5);
%end


%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

% -------------------------------------------------
% Task 1 setup
% -------------------------------------------------

sensor_pin = "A0";      % analogue input for MCP9700A

% Use 600 for the real coursework submission

duration = 600;

date_string = input('Enter date in the format d/m/yyyy: ','s');
location_string = input('Enter location: ','s');

% MCP9700A constants
V0 = 0.5;      % voltage at 0 deg C (V)
TC = 0.01;     % temperature coefficient (V/deg C)

% -------------------------------------------------
% Create arrays
% -------------------------------------------------

number_of_samples = duration + 1;

time_seconds = zeros(number_of_samples,1);
voltage_values = zeros(number_of_samples,1);
temperature_values = zeros(number_of_samples,1);

% -------------------------------------------------
% Read voltage approximately every 1 second
% -------------------------------------------------

disp('Starting temperature data acquisition...')

for n = 1:number_of_samples
    
    time_seconds(n) = n - 1;
    
    voltage_values(n) = readVoltage(a, sensor_pin);
    
    temperature_values(n) = (voltage_values(n) - V0) / TC;
    
    if n < number_of_samples
        pause(1);
    end
    
end

disp('Temperature data acquisition finished.')

% -------------------------------------------------
% Calculate minimum, maximum and average temperature
% -------------------------------------------------

min_temp = temperature_values(1);
max_temp = temperature_values(1);
temp_sum = 0;

for n = 1:number_of_samples
    
    temp_sum = temp_sum + temperature_values(n);
    
    if temperature_values(n) < min_temp
        min_temp = temperature_values(n);
    end
    
    if temperature_values(n) > max_temp
        max_temp = temperature_values(n);
    end
    
end

average_temp = temp_sum / number_of_samples;

% -------------------------------------------------
% Plot temperature against time
% -------------------------------------------------

% Smooth the short noise
temperature_plot = movmean(temperature_values, 5); 

figure
plot(time_seconds, temperature_plot, 'LineWidth', 1.2)
xlabel('Time (s)')
ylabel('Temperature (C)')
title('Capsule temperature against time')
grid on
ylim([0 40])

ax = gca;
ax.Toolbar.Visible = 'off';

exportgraphics(gcf,'temperature_time_plot.png')

% -------------------------------------------------
% Decide how many full minutes can be printed
% -------------------------------------------------

minutes_to_print = floor(duration / 60);

% -------------------------------------------------
% Print formatted output to screen using sprintf
% -------------------------------------------------

header_1 = sprintf('Data logging initiated - %s', date_string);
header_2 = sprintf('Location - %s', location_string);

disp(header_1)
disp(header_2)
disp(' ')

for minute = 0:minutes_to_print
    
    index = minute * 60 + 1;
    
    line_1 = sprintf('Minute %d', minute);
    line_2 = sprintf('Temperature %.2f C', temperature_values(index));
    
    disp(line_1)
    disp(line_2)
    disp(' ')
    
end

line_max = sprintf('Max temp %.2f C', max_temp);
line_min = sprintf('Min temp %.2f C', min_temp);
line_avg = sprintf('Average temp %.2f C', average_temp);

disp(line_max)
disp(line_min)
disp(line_avg)
disp('Data logging terminated')

% -------------------------------------------------
% Write the same data to a text file
% -------------------------------------------------

file_id = fopen('capsule_temperature.txt','w');

fprintf(file_id,'Data logging initiated - %s\n', date_string);
fprintf(file_id,'Location - %s\n\n', location_string);

for minute = 0:minutes_to_print
    
    index = minute * 60 ;
    
    fprintf(file_id,'Minute %d\n', minute);
    fprintf(file_id,'Temperature %.2f C\n\n', temperature_values(index));
    
end

fprintf(file_id,'Max temp %.2f C\n', max_temp);
fprintf(file_id,'Min temp %.2f C\n', min_temp);
fprintf(file_id,'Average temp %.2f C\n', average_temp);
fprintf(file_id,'Data logging terminated\n');

fclose(file_id);

% -------------------------------------------------
% Check that the file has been written successfully
% -------------------------------------------------

check_file = fopen('capsule_temperature.txt','r');

if check_file == -1
    disp('Error: capsule_temperature.txt could not be opened.')
else
    disp('capsule_temperature.txt has been written successfully.')
    fclose(check_file);
end


%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

disp(' ')
disp('Task 2 is now starting.')
disp('Close the Task 2 figure window when you want to stop Task 2 and continue to Task 3.')

temp_monitor(a)

disp('Task 2 finished.')
disp('Task 3 is now starting.')


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

disp('Close the Task 3 figure window when you want to stop the program.')

temp_prediction(a)

