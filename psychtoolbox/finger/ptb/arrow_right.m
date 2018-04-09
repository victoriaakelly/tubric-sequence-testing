xCenter = centerhoriz;
yCenter = centervert;

% Number of sides for our polygon
LineWidth = 15;
LineLength = 150;
ArrowLength = LineLength/2;
ArrowProj = ArrowLength * sin(pi/4);

% Here we use to a waitframes number greater then 1 to flip at a rate not
% equal to the monitors refreash rate. For this example, once per second,
% to the nearest frame
ifi = Screen('GetFlipInterval', mywindow);

flipSecs = 1;
waitframes = round(flipSecs / ifi);

% Flip outside of the loop to get a time stamp
vbl = Screen('Flip', mywindow);

% Run until a key is pressed
Nrep = duration;

for i = 1:Nrep
    
    randomcolor = rand(1, 3);
    
    Screen('DrawLine', mywindow, randomcolor, xCenter - LineLength, yCenter, ...
       xCenter + LineLength, yCenter, LineWidth);
    Screen('DrawLine', mywindow, randomcolor, xCenter + LineLength, yCenter, xCenter + LineLength - ArrowProj, ...
       yCenter + ArrowProj, LineWidth);
    Screen('DrawLine', mywindow, randomcolor, xCenter + LineLength, yCenter, xCenter + LineLength - ArrowProj, ...
       yCenter - ArrowProj, LineWidth);

    % Flip to the screen
    vbl = Screen('Flip', mywindow, vbl + (waitframes - 0.5) * ifi);
    
    if i == 1
		right_onset = GetSecs - startsecs;
	end

end

