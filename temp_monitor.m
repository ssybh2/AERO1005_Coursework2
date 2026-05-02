% NAME: Boyang Hu
% Email: ssybh2@nottingham.edu.cn

function temp_monitor(a)
%TEMP_MONITOR Continuously monitors temperature and controls LEDs.
% This function reads temperature from an MCP9700A sensor connected to
% Arduino, updates a live graph, and controls three LEDs according to
% the measured temperature. Close the figure window to stop monitoring
% and return to the main script.

% -------------------------------------------------
% Pin definitions
% -------------------------------------------------
sensor_pin = "A0";
green_led  = "D8";
yellow_led = "D9";
red_led    = "D10";

% MCP9700A constants
V0 = 0.5;
TC = 0.01;

% -------------------------------------------------
% Temperature limits
% -------------------------------------------------
lower_limit = 18;
upper_limit = 24;

% Hysteresis margin to reduce rapid switching
margin = 0.5;

% Smoothing factor
alpha = 0.2;

% -------------------------------------------------
% Create arrays for live plotting
% -------------------------------------------------
max_points = 300;
time_data = zeros(max_points,1);
temp_data = zeros(max_points,1);

% -------------------------------------------------
% Set up figure
% -------------------------------------------------
fig = figure('Name','Task 2 - Temperature Monitoring', ...
             'NumberTitle','off');
h = plot(time_data, temp_data, 'LineWidth', 1.2);
xlabel('Time (s)')
ylabel('Temperature (C)')
title('Live capsule temperature monitoring')
grid on

start_time = tic;
point_count = 0;

% State:
% 1 = yellow
% 2 = green
% 3 = red
current_state = 2;

% Initialise filtered temperature
filtered_temperature = 24;

% -------------------------------------------------
% Continuous monitoring loop
% Close the figure window to stop Task 2
% -------------------------------------------------
while isvalid(fig)
    
    % ---------------------------------------------
    % Read voltage 5 times and average
    % ---------------------------------------------
    voltage_sum = 0;
    for k = 1:5
        voltage_sum = voltage_sum + readVoltage(a, sensor_pin);
        pause(0.01);
    end
    
    voltage_value = voltage_sum / 5;
    raw_temperature = (voltage_value - V0) / TC;
    
    % ---------------------------------------------
    % Smooth temperature
    % ---------------------------------------------
    filtered_temperature = (1 - alpha) * filtered_temperature + alpha * raw_temperature;
    temperature_value = filtered_temperature;
    
    % ---------------------------------------------
    % Update arrays
    % ---------------------------------------------
    point_count = point_count + 1;
    
    if point_count > max_points
        time_data(1:max_points-1) = time_data(2:max_points);
        temp_data(1:max_points-1) = temp_data(2:max_points);
        point_count = max_points;
    end
    
    time_data(point_count) = toc(start_time);
    temp_data(point_count) = temperature_value;
    
    % ---------------------------------------------
    % Update graph
    % ---------------------------------------------
    if ~isvalid(fig)
        break
    end
    
    set(h,'XData',time_data(1:point_count), ...
          'YData',temp_data(1:point_count))
    
    xlim([max(0, time_data(point_count)-60), time_data(point_count)+1])
    ylim([15 35])
    
    drawnow
    
    % ---------------------------------------------
    % State decision with hysteresis
    % ---------------------------------------------
    if current_state == 2
        % currently green
        if temperature_value < (lower_limit - margin)
            current_state = 1;
        elseif temperature_value > (upper_limit + margin)
            current_state = 3;
        end
        
    elseif current_state == 1
        % currently yellow
        if temperature_value > (lower_limit + margin)
            current_state = 2;
        end
        
    else
        % currently red
        if temperature_value < (upper_limit - margin)
            current_state = 2;
        end
    end
    
    % ---------------------------------------------
    % LED control
    % ---------------------------------------------
    if current_state == 2
        
        % Green LED constant on for about 1 second
        writeDigitalPin(a, green_led, 1);
        writeDigitalPin(a, yellow_led, 0);
        writeDigitalPin(a, red_led, 0);
        pause(1.0);
        
    elseif current_state == 1
        
        % Yellow LED: 0.5 s on, 0.5 s on
        writeDigitalPin(a, green_led, 0);
        writeDigitalPin(a, red_led, 0);
        
        writeDigitalPin(a, yellow_led, 1);
        pause(0.5);
        
        if ~isvalid(fig)
            break
        end
        
        writeDigitalPin(a, yellow_led, 0);
        pause(0.5);
        
    else
        
        % Red LED: 0.25 s on/off intervals
        writeDigitalPin(a, green_led, 0);
        writeDigitalPin(a, yellow_led, 0);
        
        writeDigitalPin(a, red_led, 1);
        pause(0.25);
        if ~isvalid(fig), break, end
        
        writeDigitalPin(a, red_led, 0);
        pause(0.25);
        if ~isvalid(fig), break, end
        
        writeDigitalPin(a, red_led, 1);
        pause(0.25);
        if ~isvalid(fig), break, end
        
        writeDigitalPin(a, red_led, 0);
        pause(0.25);
        
    end
    
end

% -------------------------------------------------
% Turn all LEDs off before leaving the function
% -------------------------------------------------
writeDigitalPin(a, green_led, 0);
writeDigitalPin(a, yellow_led, 0);
writeDigitalPin(a, red_led, 0);

disp('Task 2 monitoring stopped by user.')
end