clear all;
close all;

subix  = 'Enter subject name: ';
subID  = input(subix,'s');
prompt = 'Enter block number: ';
subjectnum = input(prompt);

if ~ischar(subjectnum)
    subjectnum = num2str(subjectnum);
end
Screen('Preference', 'SkipSyncTests', 1);

%Make outputdir if it does not already exist%%%
maindir = pwd;
outputdir = fullfile(maindir,'data',subID,subjectnum);
if ~exist(outputdir,'dir')
    mkdir(outputdir);
end
addpath(fullfile(maindir,'ptb'));

RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
PsychDefaultSetup(2);
ExpStartTime = GetSecs;

ntrials = 5;

try    
    % set up screens and rects
    myptb_setup;
    % set all Trial Information
    trial_setup;
%         
        WaitSecs(2);
%         
%       fix1_list = Shuffle(fix1_list);
        fix2_list = Shuffle(fix2_list);  
%         
        msg1 = sprintf('Get Ready!');
        Screen('TextSize', mywindow, floor((30*scale_res(2))));
        Screen('TextFont', mywindow, 'Helvetica');
        Screen('TextStyle', mywindow, 0);
        longest_msg = 'During this task, you will see arrows pointing to either side of the screen.';
        [normBoundsRect, ~] = Screen('TextBounds', mywindow, longest_msg);
        
        %%%Setting the intro screen%%%
        Screen('TextSize', mywindow, floor((25*scale_res(2))));
        Screen('TextStyle', mywindow, 1);
        Screen('DrawText', mywindow, msg1, (centerhoriz-(normBoundsRect(3)/2)), (centervert-(90*scale_res(2))), black);
        Screen('TextStyle', mywindow, 0);
        Screen('DrawText', mywindow, 'Once you see an arrow, you should tap your index finger on the hand that arrow is pointing to.', (centerhoriz-(normBoundsRect(3)/2)), (centervert-(35*scale_res(2))), black);
        Screen('DrawText', mywindow, longest_msg, (centerhoriz-(normBoundsRect(3)/2)), centervert, black);
        Screen('DrawText', mywindow, 'For example, you should tap your left index finger when the arrow points to the left', (centerhoriz-(normBoundsRect(3)/2)), (centervert+(35*scale_res(2))), black);
        Screen('DrawText', mywindow, 'Please keep your head/legs still. The task will start soon.', (centerhoriz-(normBoundsRect(3)/2)), (centervert+(70*scale_res(2))), black);
        %oldTextSize=Screen('TextSize', mywindowPtr [,textSize]);
        Screen('Flip', mywindow);
        
        wait_for_trigger;
        fixation_ptb;
            
         outputname = fullfile(outputdir, [subjectnum '_finger.mat']);
         startsecs = GetSecs;
         
         for k = 1:ntrials
%             
    
		     [left_onset, right_onset] = deal(0);            
		      eventsecs = GetSecs; %start event clock
             
            if k == 1
                delayt = 4;
                WaitSecs(delayt);
            else
                delayt = 0;
            end
             
             arrow_left;
             WaitSecs(1);
             
             fixation_ptb;
             
             while GetSecs - (eventsecs+delayt+duration) < fix1_list(k) %timing loop
					[~, ~, keyCode] = KbCheck; %Keyboard input
					if find(keyCode) == esc_key %escape
						abort_all;
					end
			 end
             
             arrow_right;
             WaitSecs(1);
             
             fixation_ptb;
             
             while GetSecs - (eventsecs+delayt+2*duration + fix1_list(k)) < fix2_list(k)
					[~, ~, keyCode] = KbCheck; %Keyboard input
					if find(keyCode) == esc_key %escape
						abort_all;
                    end
             end
                         
             
            % Save data here
            data_struct;
            
         end
        
        while (GetSecs - startsecs) < 280
        end
        run_time = GetSecs - startsecs;
        save(outputname, 'data','run_time');
        WaitSecs(2);
    
    
    Screen('TextSize', mywindow, floor((30*scale_res(2))));
    msg = sprintf('finished!');
    [normBoundsRect, ~] = Screen('TextBounds', mywindow, msg);
    Screen('DrawText', mywindow, msg, (centerhoriz-(normBoundsRect(3)/2)), (centervert-(normBoundsRect(4)/2)), black);
    Screen('Flip', mywindow);
    
    wait_for_esc;
    
    sca;
    task_dur = GetSecs - ExpStartTime;
    task_dur_info = fullfile(outputdir, [subjectnum '_fingerDuration.mat']);
    save(task_dur_info, 'task_dur','task_dur');
    ss.stop;
    % Probably a good idea to save the impedances with the rest of our data.
    ss.z
    ss.zTime


catch ME
	disp(ME.message);
    sca;
    keyboard
    ss.stop;
    ss.z
    ss.zTime
    keyboard
end



