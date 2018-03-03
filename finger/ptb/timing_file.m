subject = 1;
maindir = pwd;
datadir = fullfile(maindir,'data',num2str(subject));
outputdir = fullfile(maindir,'evfiles_finger',num2str(subject));
if ~exist(outputdir,'dir')
    mkdir(outputdir);
end

r = 1;
    
    load(fullfile(datadir,sprintf('%s_finger.mat',num2str(subject)))) % '%s_reward_%d.mat'

    
    ntrials = length(data);
    dur = 20*ones(ntrials,1);
    constant = ones(ntrials,1);
    
   for i = 1:ntrials
       left(i) = data(i).left_onset;
       right(i) = data(i).right_onset;
   end
    %make empty mats (for *_par, will make *_con last)
    left = [left',dur,constant];
    right = [right',dur,constant];
    
    cd(outputdir);
    dlmwrite(sprintf('left%d.txt'),left,'delimiter','\t','precision','%.6f')
    dlmwrite(sprintf('right%d.txt'),right,'delimiter','\t','precision','%.6f')
    cd(maindir);

