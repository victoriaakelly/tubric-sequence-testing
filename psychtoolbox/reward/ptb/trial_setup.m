ntrials = 36;
fix1_list = [repmat(2,1,22) repmat(4,1,10) repmat(6,1,4)];
fix2_list = fix1_list;

self_dec = 2.50;
infodur = 1.75;

point_total = 0;
randblocks = 1:2; %not random

payout = load(payout);

clear data;