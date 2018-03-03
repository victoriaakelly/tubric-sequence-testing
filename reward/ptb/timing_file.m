subject = 1;
maindir = pwd;
datadir = fullfile(maindir,'data',num2str(subject));
outputdir = fullfile(maindir,'evfiles',num2str(subject));
if ~exist(outputdir,'dir')
    mkdir(outputdir);
end

blocks = 1:2;
for r = 1:length(blocks)
    
    load(fullfile(datadir,sprintf('%s_feedback_%d.mat',num2str(subject),r))) % '%s_reward_%d.mat'
    choicedata = [data.feedback; data.deckchoice]';
    
    % estimate learning
    out = choicedata(:,1);
    dec = choicedata(:,2);
    
    alpha = 0.30;
    beta = 2;
    [exp_c, exp_u, pe_e] = runRW(dec, out, alpha, beta);
    
    ntrials = length(data);
    
    %make empty mats (for *_par, will make *_con last)
    decision = zeros(ntrials,3);
    decision_c = decision;
    decision_u = decision;
    inf_par = zeros(ntrials,3);
    lapse1 = zeros(ntrials,3);
    
    for t = 1:ntrials
        
        if data(t).lapse1
            lapse1(t,1) = data(t).choice_onset;
            lapse1(t,2) = 2.5;
            lapse1(t,3) = 1;
        else
            decision(t,1) = data(t).choice_onset;
            decision(t,2) = data(t).RT1;
            decision(t,3) = 1;
            
            decision_c(t,1) = data(t).choice_onset;
            decision_c(t,2) = data(t).RT1;
            decision_c(t,3) = exp_c(t);
            
            decision_u(t,1) = data(t).choice_onset;
            decision_u(t,2) = data(t).RT1;
            decision_u(t,3) = exp_u(t);
            
            inf_par(t,1) = data(t).info_onset;
            inf_par(t,2) = 1.75;
            inf_par(t,3) = pe_e(t);
            
        end
    end
    
    decision(~decision(:,1),:) = [];
    lapse1(~lapse1(:,1),:) = [];
    
    % demean parametric regressors
    inf_par(~inf_par(:,1),:) = [];
    
    % make constants
    inf_con = inf_par;
    inf_con(:,3) = 1;
    
    cd(outputdir);
    dlmwrite(sprintf('inf_con%d.txt',r),inf_con,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('inf_par%d.txt',r),inf_par,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('decision%d.txt',r),decision,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('decision_c%d.txt',r),decision_c,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('decision_u%d.txt',r),decision_u,'delimiter','\t','precision','%.6f')
    cd(maindir);
end
