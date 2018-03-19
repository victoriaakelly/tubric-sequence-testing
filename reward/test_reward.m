clear all;
close all;

subix  = 'Enter subject name: ';
subID  = input(subix,'s');
prompt = 'Enter block number: ';
subjectnum = input(prompt);
seq = randi([1 4], 1, 1);
payout = ['payout_v' num2str(seq) '.mat'];

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

try    
    % set up screens and rects
    myptb_setup;
    
    % set all Trial Information
    highval_count = 0;
    %scanner_practice;
    trial_setup;
    
    cues(1) = subjectnum; %randi([1 4],1,1);
    cues(2) = cues(1) + 4;
    
    for b = 1:length(randblocks)
        block = randblocks(b);
        
        blocktrials = 1+(ntrials*(block-1)):(ntrials*block);
        
        %distribute payout probabilities
        deck1 = payout.data(blocktrials,1); 
        deck2 = payout.data(blocktrials,2);
        
        [imagename, ~, alpha] = imread(fullfile(maindir,'imgs',['Cue' num2str(cues(1)) '.png']));
        imagename(:,:,4) = alpha(:,:);
        scan1_texture = Screen('MakeTexture', mywindow, imagename);
        [imagename, ~, alpha] = imread(fullfile(maindir,'imgs',['Cue' num2str(cues(2)) '.png']));
        imagename(:,:,4) = alpha(:,:);
        scan2_texture = Screen('MakeTexture', mywindow, imagename);
        
        WaitSecs(2);
        
        fix1_list = Shuffle(fix1_list);
        fix2_list = Shuffle(fix2_list);
        deckorders = [1 2; 2 1];
        
        msg1 = sprintf('Run %d of %d: Get Ready!', b, length(randblocks));
        Screen('TextSize', mywindow, floor((30*scale_res(2))));
        Screen('TextFont', mywindow, 'Helvetica');
        Screen('TextStyle', mywindow, 0);
        longest_msg = 'Each token is associated with a different probability of reward ($1) that will change slowly over time.';
        [normBoundsRect, ~] = Screen('TextBounds', mywindow, longest_msg);
        
        %%%Setting the intro screen%%%
        Screen('TextSize', mywindow, floor((25*scale_res(2))));
        Screen('TextStyle', mywindow, 1);
        Screen('DrawText', mywindow, msg1, (centerhoriz-(normBoundsRect(3)/2)), (centervert-(90*scale_res(2))), black);
        Screen('TextStyle', mywindow, 0);
        Screen('DrawText', mywindow, 'During this task, you will make choices between two tokens (with different greek letters).', (centerhoriz-(normBoundsRect(3)/2)), (centervert-(35*scale_res(2))), black);
        Screen('DrawText', mywindow, longest_msg, (centerhoriz-(normBoundsRect(3)/2)), centervert, black);
        Screen('DrawText', mywindow, 'Keep track of the reward probability of each token and choose accordingly.', (centerhoriz-(normBoundsRect(3)/2)), (centervert+(35*scale_res(2))), black);
        Screen('DrawText', mywindow, 'Please keep your head/legs still. The task will start soon.', (centerhoriz-(normBoundsRect(3)/2)), (centervert+(70*scale_res(2))), black);
        %oldTextSize=Screen('TextSize', mywindowPtr [,textSize]);
        Screen('Flip', mywindow);        
        
        
        wait_for_trigger;
        fixation_ptb;
        
        % START TRIAL LOOP%%%
        outputname = fullfile(outputdir, [subjectnum '_reward_' num2str(b) '.mat']);
        startsecs = GetSecs;
        for k = 1:ntrials
            
            [lapse1, RT1] = deal(0);
            [choice_onset, press1_onset, info_onset, value] = deal(0);
            deckorder = deckorders(ceil(rand*2),:);
            
            eventsecs = GetSecs; %start event clock
            if k == 1
                delayt = 4;
                WaitSecs(delayt);
            else
                delayt = 0;
            end
            
                
			% Choice phase
			prechoice_ptb;
			press = 0;
			while ~press
				[~, ~, responsecode] = KbCheck; %Keyboard input
				if GetSecs - (eventsecs+delayt) > self_dec
					lapse_ptb;
					lapse1 = 1;
				else
					% runs all the stuff for getting the choice
					choice_ptb;
				end
			end
			WaitSecs(.5);
			
			% if the don't response, then fixation for the rest of the trial
			if lapse1
				fixation_ptb;
                correct = nan;
				while GetSecs - (eventsecs+delayt+self_dec) < fix1_list(k)+infodur+fix2_list(k)
					[~, ~, keyCode] = KbCheck; %Keyboard input
					if find(keyCode) == esc_key %escape
						abort_all;
					end
				end
			else
				
				% fixation #1
				fixation_ptb;
				while GetSecs - (eventsecs+delayt+self_dec) < fix1_list(k) %timing loop
					[~, ~, keyCode] = KbCheck; %Keyboard input
					if find(keyCode) == esc_key %escape
						abort_all;
					end
				end
				
				
				% Feedback
                choice = choice/100;
                disp(num2str(choice));%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				correct = rand < choice;
				if correct == 1
					Screen('DrawTexture', mywindow, reward_texture, [], MiddleRect);
				elseif correct == 0
					Screen('DrawTexture', mywindow, no_reward_texture, [], MiddleRect);
				end
				
				Screen('Flip', mywindow);
				info_onset = GetSecs - startsecs;
				while GetSecs - (eventsecs+delayt+self_dec+fix1_list(k)) < infodur %timing loop
					[~, ~, keyCode] = KbCheck; %Keyboard input
					if find(keyCode) == esc_key %escape
						abort_all;
					end
                end
            
				
				
            % Fixation #2
            fixation_ptb;
            while GetSecs - (eventsecs+delayt+self_dec+fix1_list(k)+infodur) < fix2_list(k) %timing loop
                [~, ~, keyCode] = KbCheck; %Keyboard input
                if find(keyCode) == esc_key %escape
                    abort_all;
                end
            end
		
        end
            % Save data here
            data_struct;
            
    end
        
        while (GetSecs - startsecs) < 380
        end
        run_time = GetSecs - startsecs;
        save(outputname, 'data','run_time');
        WaitSecs(2);
    end
    
    Screen('TextSize', mywindow, floor((30*scale_res(2))));
    msg = sprintf('finished!');
    [normBoundsRect, ~] = Screen('TextBounds', mywindow, msg);
    Screen('DrawText', mywindow, msg, (centerhoriz-(normBoundsRect(3)/2)), (centervert-(normBoundsRect(4)/2)), black);
    Screen('Flip', mywindow);
    
    wait_for_esc;
    
    sca;
    task_dur = GetSecs - ExpStartTime;
    task_dur_info = fullfile(outputdir, [subjectnum '_TaskDuration.mat']);
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

