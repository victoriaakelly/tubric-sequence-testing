subject = 1;
maindir = pwd;
datadir = fullfile(maindir,'data',num2str(subject));
outputdir = fullfile(maindir,'evfiles_finger',num2str(subject));
if ~exist(outputdir,'dir')
    mkdir(outputdir);
end

 r = 1;
    
    load(fullfile(datadir,sprintf('%s_mid.mat',num2str(subject)))) % '%s_reward_%d.mat'
    
    outcome = output.outcome;
    
    ntrials = length(outcome);
    
    cue     = output.trial_starts;
    cue_dur = ones(ntrials,1);
    target  = output.target_starts;
    RT      = output.RT;
    cond    = output.condition;
    constant = ones(ntrials,1);
   
    
    %make empty mats (for *_par, will make *_con last)
    cue_mat = [cue',cue_dur,constant];
    
    high = find(cond==1);
    low  = find(cond==2);
    cue_high = cue_mat(high,:);
    cue_low  = cue_mat(low,:);
    
    feedback = [target',RT',constant];
    hit = find(outcome == 1);%
    miss = find(outcome == 0);%
    
    r_high_hit  = intersect(high,hit);
    r_high_miss = intersect(high,miss);
    r_low_hit   = intersect(low,hit);
    r_low_miss  = intersect(low,miss);
    
    high_hit = feedback(r_high_hit,:);%
    high_miss = feedback(r_high_miss,:);%
    low_hit = feedback(r_low_hit,:);%
    low_miss = feedback(r_low_miss,:);%
    
    cd(outputdir);
    dlmwrite(sprintf('high%d.txt',r),cue_high,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('low%d.txt',r),cue_low,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('high_hit%d.txt',r),high_hit,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('high_miss%d.txt',r),high_miss,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('low_hit%d.txt',r),low_hit,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('low_miss%d.txt',r),low_miss,'delimiter','\t','precision','%.6f')
    cd(maindir);
