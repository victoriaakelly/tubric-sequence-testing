function [exp_c, exp_u, pe_e]  = runRW(decision, outcome, alpha, beta)

try
    
    %Choice: 1 = deck1; 2 = deck2; 3 = deck3
    %Outcome: 0, 1, 2, 3
    data = [ decision(:,1), outcome(:,1)];
    
    %Standard RW: 2 Parameter
    
    %Free parameters
    %alpha = xpar(1);
    %beta = xpar(2);
    
    
    %Set initial values
    pvt = 1;
    vD1(1:pvt) = 0; %mean(data(data(1:pvt,1)==1 | data(1:pvt,1)==11,2));
    vD2(1:pvt) = 0; %mean(data(data(1:pvt,1)==2 | data(1:pvt,1)==22,2));
    pD1(1:pvt) = 1/2;
    pD2(1:pvt) = 1/2;
    loglike_e = 0;
    pe(1:pvt) = 0;
    exp_c = 0;
    exp_u = 0;
    
    
    for trialnum = pvt:size(data,1)
        
        %Update log-likelihood -- switching to max loglikelihood
        if data(trialnum,1) == 1
            loglike_e = loglike_e + log(pD1(trialnum));
        elseif data(trialnum,1) == 2
            loglike_e = loglike_e + log(pD2(trialnum));
        end
        
        
        
            if data(trialnum,1) == 1 || data(trialnum,1) == 11 %deck1 action
                pe(trialnum) = data(trialnum,2) - vD1(trialnum);
                vD1(trialnum + 1) = vD1(trialnum) + alpha * pe(trialnum);
                vD2(trialnum + 1) = vD2(trialnum); %if not selected continue value to nxt trial
                exp_c(trialnum) = vD1(trialnum);
                exp_u(trialnum) = vD2(trialnum);
            elseif data(trialnum,1) == 2 || data(trialnum,1) == 22 %deck2 action
                pe(trialnum) = data(trialnum,2) - vD2(trialnum);
                vD2(trialnum + 1) = vD2(trialnum) + alpha * pe(trialnum);
                vD1(trialnum + 1) = vD1(trialnum); %if not selected continue value to nxt trial
                exp_c(trialnum) = vD2(trialnum);
                exp_u(trialnum) = vD1(trialnum);
            end
            %Calculate probability using softmax
            pD1(trialnum + 1) = exp(vD1(trialnum+1)/beta) / ( exp(vD1(trialnum+1)/beta) + exp(vD2(trialnum+1)/beta) );
            pD2(trialnum + 1) = exp(vD2(trialnum+1)/beta) / ( exp(vD1(trialnum+1)/beta) + exp(vD2(trialnum+1)/beta) );
            %pCir(trialnum + 1) = exp(vCir(trialnum+1)/beta) / ( exp(vDia(trialnum+1)/beta) + exp(vCir(trialnum+1)/beta));
        
        
    end
    %figure,plot(pD1,'r')
    %hold on
    %plot(pD2,'g')
    %plot(pD3,'b')
    %title(['beta is ' num2str(beta)])
    pe_e = pe - mean(pe);
    exp_c = exp_c - mean(exp_c);
    exp_u = exp_u - mean(exp_u);
    alpha_e = alpha;
    beta_e = beta;
catch ME
    disp(ME.message)
    keyboard;
end

