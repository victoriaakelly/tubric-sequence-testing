%function MID2(isscan, subnum)

subID = input('Enter subject name: ', 's');
isscan = input('practice = 0 block = 1:4 : ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%subnum - subject number is 0 for practice, real number if it is a run
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'SkipSyncTests', 1);
global thePath; rand('state',sum(100*clock));

% Add this at top of new scripts for maximum portability due to unified names on all systems:
KbName('UnifyKeyNames');
%Screen('Preference', 'VisualDebuglevel', 3);

thePath.start = pwd;                                % starting directory
thePath.data = fullfile(thePath.start, 'data');     % path to Data directory
thePath.scripts = fullfile(thePath.start, 'scripts');
thePath.stims = fullfile(thePath.start, 'stimuli');

addpath(thePath.scripts)
addpath(thePath.stims)

% set up device number
if IsOSX
    k = GetKeyboardIndices;
else
    k = 1;
end

%%%%%% CONSTANT DECLARED VARIABLES %%%%%%%%%%%%%%%
if isscan == 0          % keyboard being used as input
    KeysVal=[4 22 7 9 11 13 14 15 89];
    % kbname('a')=4, kbname('s')=22, kbname('d')=7 kbname('f')=9
    % kbname('h')=11, kbname('j')=13, kbname('k')=14 kbname('l')=15
    % kbname('1')=89
else
    KeysVal=[89:92 30:34]; %%To be determined in the near future
end

text_size = 40;
disdaq = 1;
ms=0.06;                    %duration of time post-target until responses are accepted (no keys accepted)

%define intertrial fixation
a = Shuffle([(ones(1,13)+1) (ones(1,14)+2) (ones(1,13)+3)]);
b = Shuffle([(ones(1,13)-.9) zeros(1,14) (ones(1,13)-1.1)]);

if isscan == 0          % keyboard being used as input
trial_cond = Shuffle([ones(1,20) ones(1,20)+1]);
fix2_duration = Shuffle([ones(1,20)+2 ones(1,20)+4]);
fix1_duration = a+b;
stim = [];
else
load([thePath.scripts '/' num2str(randi(4,1)) '.mat']);
trial_cond = stim.condition;
fix2_duration = stim.fixation;
fix1_duration = a+b;
end



backtick = '=';
mkdir(fullfile(thePath.data,subID));
RTs  =[];
try
    practice_files = ls([fullfile(thePath.data ,subID), '/practice_array.mat']);
catch
    practice_files = [];
end

if ~isempty(practice_files)                             % checks to see whether there is practice data or not. Overwrite if there is
    load(practice_files,'RTs'); % (1:end-1) practice_files has an extra space character added to the string name, hence the 1:end-1 in the code
end

for i=1:length(unique(trial_cond))                     % sets starting RT_thresh for each condition
    if isempty(practice_files)
        [RT_thresh(i)] = set_MID_threshold([]);
    else
        [RT_thresh(i)] = set_MID_threshold(RTs(:,i));
    end
end
Screen('CloseAll')

trial_starts = []; %trial starts not including saturation scans

%%%SET UP SCREEN PARAMETERS FOR PTB
screens = Screen('Screens');
%Make sure this is alright
screenNumber = max(screens); HideCursor;
[Screen_X, Screen_Y]=Screen('WindowSize',0);

% USE THESE LINES FOR SET SCREEN
screenRect = [ 0 0 1024 768];
[Window, Rect] = Screen('OpenWindow', screenNumber, 0);%, screenRect);
Screen('TextSize',Window,text_size);
Screen('FillRect', Window, 0);  % 0 = black background


% LOAD STIMULI
DrawFormattedText(Window, 'loading stimuli....', 'center', 'center', 255);
Screen('Flip', Window);

high_cue = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'high'), 'png'));
low_cue = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'low'), 'png'));
target = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'target'), 'bmp'));
fix1 = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'fix1'), 'png'));
fix2 = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'fix2'), 'png'));

% INSTRUCTIONS
DrawFormattedText(Window, 'Your goal is to make as much money as possible ', 'center', .1*Rect(4), 255);
DrawFormattedText(Window, 'Each trial will begin with a cue: ', 'center', .2*Rect(4), 255);
DrawFormattedText(Window, 'The color of the star indicates how much you can earn.', 'center', .3*Rect(4), 255);
DrawFormattedText(Window, 'After each cue you will see a solid white square, or "target".', 'center', .4*Rect(4), 255);
DrawFormattedText(Window, 'Respond as fast as possible to the white target when it appears.', 'center', .5*Rect(4), 255);
DrawFormattedText(Window, 'Earning GREEN stars work towards a $20 bonus.', 'center', .6*Rect(4), 255);
DrawFormattedText(Window, 'Earning GRAY stars work towards a $1 bonus.', 'center', .7*Rect(4), 255);


Screen('Flip', Window); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if IsOSX
    getKey(backtick, k);                             % wait for backtick before continuing
else
    getKey(backtick);
end
%%%%%%%%%%%%%%%%%%%%%%%% BEGIN TRIAL LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%wait for button press

% record run start time (post disdaqs) CHECK ON WHEN IT SENDS TRIGGER

% DrawFormattedText(Window, 'Get Ready!', 'center', 'center', 255);
% Screen('Flip', Window);
% 
% if IsOSX
%     getKey(backtick, k);                             % wait for backtick before continuing
% else
%     getKey(backtick);
% end

tic
runST = GetSecs;
Screen('DrawTexture', Window, fix2);
Screen('Flip', Window);
WaitSecs(2);

for t = 1:length(trial_cond)
    %Present Cue
    if trial_cond(t) == 1
        Screen('DrawTexture', Window, high_cue);
    elseif trial_cond(t) == 2
        Screen('DrawTexture', Window, low_cue);
    end
    stimST = Screen('Flip', Window);
    WaitSecs(1)
    
    %Present Fix1
    Screen('DrawTexture', Window, fix1);
    Screen('Flip', Window);
    WaitSecs(fix1_duration(t))
    
    %Present Target
    Screen('DrawTexture', Window, target);
    targetST = Screen('Flip', Window);
    [keys, RT] = recordKeysNoBT(GetSecs, 1, k, backtick);
    
    text_feedback = '';
    %Present Feedback
    if RT(1) == 0
        output.outcome(t) = 0;
        text_feedback = 'You did not earn a star.';
    elseif RT(1) < RT_thresh(trial_cond(t))
        output.outcome(t) = 1;
        if trial_cond(t) == 1
            text_feedback = 'You earned a green star!';
        elseif trial_cond(t) ==2
            text_feedback = 'You earned a gray star!';
        end
    else
        output.outcome(t) = 0;
        text_feedback = 'You did not earn a star.';
    end
    
    RTs(end+1, trial_cond(t)) = RT(1);
    
    DrawFormattedText(Window, text_feedback, 'center', 'center', 255);
    Screen('Flip', Window);
    WaitSecs(1)
    
    %Present Fix2
    Screen('DrawTexture', Window, fix2);
    Screen('Flip', Window);
    WaitSecs(fix2_duration(t))
    
    %Update Thresholds
    [RT_thresh(trial_cond(t))] = set_MID_threshold(RTs(:,trial_cond(t)));
    output.trial_starts(t) = stimST-runST;
    output.target_starts(t) = targetST-runST;
    output.RT(t) = RT(1);
    output.thresh(t) = RT_thresh(trial_cond(t));
end

while (GetSecs - runST) < 560
end

run_time = GetSecs - runST;
WaitSecs(2);

toc
output.dur = run_time;
output.condition = trial_cond;
output.fix1 =fix1_duration;
output.fix2 = fix2_duration;


save([thePath.data '/' subID '/output_' num2str(isscan) '.mat'], 'stim', 'output')
if isscan == 0
    save([thePath.data '/' subID '/practice_array.mat'], 'RTs')
end

sca;
