function temp_prediction(a)
%TEMP_PREDICTION Continuously predicts future capsule temperature.
% This function reads temperature from an MCP9700 sensor through Arduino,
% estimates the rate of change in degC/s, predicts temperature 5 minutes
% ahead, prints results to the Command Window, and controls LEDs.
% Green means stable temperature within 18-24 C, red means temperature
% rises faster than +4 C/min, and yellow means temperature falls faster
% than -4 C/min. Close the figure window to stop the function.


% -------------------------------------------------
% Setup initial conditions
% -------------------------------------------------

% Pin allocation for sensor input and three status LEDs
sensor_pin = "A0";
green_led  = "D8";
yellow_led = "D9";
red_led    = "D10";

% MCP9700 temperature conversion constants:
V0 = 0.5;     % Output voltage at 0 deg C 
TC = 0.01;    % Temperature cofficient in V/deg C

% Temperture range and required rate 
lower_limit = 18;
upper_limit = 24;
rate_limit = 4/60;      % Units: C/s

% Fliter against the short-term noise 
alpha = 0.2;

% Time window used to estimate a medium-term rate of change
window_seconds = 10;

% Only the most recent max_points values are kept on screen
max_points = 300;
time_data = zeros(max_points,1);
temp_data = zeros(max_points,1);

% -------------------------------------------------
% Set up figure
% -------------------------------------------------

fig = figure('Name','Task 3 - Temperature Prediction', ...
             'NumberTitle','off');
h = plot(nan, nan, 'LineWidth', 1.2);
xlabel('Time (s)')
ylabel('Temperature (C)')
title('Live temperature prediction')
grid on

start_time = tic;
point_count = 0;
filtered_temp = 24;

% -------------------------------------------------
% Continue running unless the figure window was closed
% -------------------------------------------------

while isvalid(fig)
    loop_start = tic;

    % Read voltage 5 times and average
    voltage_sum = 0;
    for k = 1:5
        voltage_sum = voltage_sum + readVoltage(a, sensor_pin);
        pause(0.01);
    end
    voltage_value = voltage_sum / 5;

    % Convert voltage to temperature
    raw_temp = (voltage_value - V0) / TC;

    % Smooth temperature
    filtered_temp = (1-alpha)*filtered_temp + alpha*raw_temp;
    current_temp = filtered_temp;

    % Update time and arrays

    % If the arrays are full, shift all data left by one position
    % so the plot always keeps only the most recent max_points samples
    point_count = point_count + 1;
    if point_count > max_points
        time_data(1:end-1) = time_data(2:end);
        temp_data(1:end-1) = temp_data(2:end);
        point_count = max_points;
    end

    current_time = toc(start_time);
    time_data(point_count) = current_time;
    temp_data(point_count) = current_temp;

    % Compute rate using medium-term window

    % Estimate temperature change rate using a medium-term time window.
    % This avoids using only two adjacent points, which would be too sensitive to noise.
    if point_count == 1
        rate_cps = 0;
    else
        idx_ref = find(time_data(1:point_count) <= current_time - window_seconds, 1, 'last');
        % During the first few seconds there may be no point that is old enough,
        % so fall back to the previous sample
        if isempty(idx_ref)
            idx_ref = max(1, point_count - 1);
        end

        dt = current_time - time_data(idx_ref);
        dT = current_temp - temp_data(idx_ref);

        if dt > 0
            rate_cps = dT / dt;
        else
            rate_cps = 0;
        end
    end

    % Predict temperature after 5 minutes
    predicted_temp = current_temp + rate_cps * 300;

    % Print to screen
    fprintf('Current temp: %.2f C | Rate: %.4f C/s (%.2f C/min) | Predicted in 5 min: %.2f C\n', ...
            current_temp, rate_cps, rate_cps*60, predicted_temp);
    
    % Update graph
    if ~isvalid(fig)
        break
    end
    
    set(h, 'XData', time_data(1:point_count), 'YData', temp_data(1:point_count))
    xlim([max(0, current_time-60), current_time+1])
    ylim([10 40])
    drawnow

% -------------------------------------------------
% LED Logic
% -------------------------------------------------

    % When the temperature increase too fast
    if rate_cps > rate_limit
        writeDigitalPin(a, red_led, 1); % The red led glow 
        writeDigitalPin(a, yellow_led, 0);
        writeDigitalPin(a, green_led, 0);
    
    % When the temperature decrease too fast
    elseif rate_cps < -rate_limit
        writeDigitalPin(a, red_led, 0);
        writeDigitalPin(a, yellow_led, 1); % The yellow led glow 
        writeDigitalPin(a, green_led, 0);
    
    % Stable condition of the temperature
    elseif current_temp >= lower_limit && current_temp <= upper_limit
        writeDigitalPin(a, red_led, 0);
        writeDigitalPin(a, yellow_led, 0);
        writeDigitalPin(a, green_led, 1); % The green led glow 

    else
        writeDigitalPin(a, red_led, 0);
        writeDigitalPin(a, yellow_led, 0);
        writeDigitalPin(a, green_led, 0);
    end

    % Keep update interval close to 1 second
    elapsed = toc(loop_start);
    pause(max(0, 1 - elapsed));
end

% -------------------------------------------------
% Turn all LEDs off before leaving the function
% -------------------------------------------------
writeDigitalPin(a, red_led, 0);
writeDigitalPin(a, yellow_led, 0);
writeDigitalPin(a, green_led, 0);

disp('Task 3 prediction stopped by user.')
end