function [output]=EMCMCsampler(minit,logPfuns,Nsamples,varargin)
%% Cascaded affine invariant ensemble MCMC sampler. "The MCMC hammer"
%
% GWMCMC is an implementation of the Goodman and Weare 2010 Affine
% invariant ensemble Markov Chain Monte Carlo (MCMC) sampler. MCMC sampling
% enables bayesian inference. The problem with many traditional MCMC samplers
% is that they can have slow convergence for badly scaled problems, and that
% it is difficult to optimize the random walk for high-dimensional problems.
% This is where the GW-algorithm really excels as it is affine invariant. It
% can achieve much better convergence on badly scaled problems. It is much
% simpler to get to work straight out of the box, and for that reason it
% truly deserves to be called the MCMC hammer.
%
% (This code uses a cascaded variant of the Goodman and Weare algorithm).
%
% USAGE:
%  [models,logP]=gwmcmc(minit,logPfuns,mccount, Parameter,Value,Parameter,Value);
%
% INPUTS:
%     minit: an WxM matrix of initial values for each of the walkers in the
%            ensemble. (M:number of model params. W: number of walkers). W
%            should be atleast 2xM. (see e.g. mvnrnd).
%  logPfuns: a cell of function handles returning the log probality of a
%            proposed set of model parameters. Typically this cell will
%            contain two function handles: one to the logprior and another
%            to the loglikelihood. E.g. {@(m)logprior(m) @(m)loglike(m)}
%   mccount: What is the desired total number of monte carlo proposals per chain.
%            This is the total number per chain before burn-in.
%
% Named Parameter-Value pairs:
%   'Nsamples': Final sample size to be obtained per chain.
%   'StepSize': unit-less stepsize (default=2).
%   'ThinChain': Thin all the chains by only storing every N'th step (default=10)
%   'ProgressBar': Show a text progress bar (default=true)
%   'Parallel': Run in ensemble of walkers in parallel. (default=false)
%   'BurnIn': Number of samples per chain that should be removed. (default=0)
%
% OUTPUTS:
%    models: A WxMxT matrix with the thinned markov chains (with T samples
%            per walker). T=~(mccount/p.ThinChain)*(1 - burnin_rate).
%    logP: A WxPxT matrix of log probabilities for each model in the
%            models. here P is the number of functions in logPfuns.
%
% Note on cascaded evaluation of log probabilities:
% The logPfuns-argument can be specifed as a cell-array to allow a cascaded
% evaluation of the probabilities. The computationally cheapest function should be
% placed first in the cell (this will typically the prior). This allows the
% routine to avoid calculating the likelihood, if the proposed model can be
% rejected based on the prior alone.
% logPfuns={logprior loglike} is faster but equivalent to
% logPfuns={@(m)logprior(m)+loglike(m)}
%
%
% References:
% Goodman & Weare (2010), Ensemble Samplers With Affine Invariance, Comm. App. Math. Comp. Sci., Vol. 5, No. 1, 65�80
% Foreman-Mackey, Hogg, Lang, Goodman (2013), emcee: The MCMC Hammer, arXiv:1202.3665
%
% WebPage: https://github.com/grinsted/gwmcmc
%
% -Aslak Grinsted 2015

persistent isoctave;  
if isempty(isoctave)
	isoctave = (exist ('OCTAVE_VERSION', 'builtin') > 0);
end

if nargin<3
    error('GWMCMC:toofewinputs','GWMCMC requires atleast 3 inputs.')
end
M=size(minit,2);
if size(minit,1)==1
    minit=bsxfun(@plus,minit,randn(M*5,M));
end


p=inputParser;
if isoctave
    p=p.addParamValue('StepSize',2,@isnumeric); %addParamValue is chosen for compatibility with octave. Still Untested.
    p=p.addParamValue('ThinChain',10,@isnumeric);
    p=p.addParamValue('ProgressBar',true,@islogical);
    p=p.addParamValue('Parallel',false,@islogical);
    p=p.addParamValue('BurnIn',0,@isnumeric);
    p=p.parse(varargin{:});
else
    p.addParameter('StepSize',2,@isnumeric); %addParamValue is chose for compatibility with octave. Still Untested.
    p.addParameter('ThinChain',10,@isnumeric);
    p.addParameter('ProgressBar',true,@islogical);
    p.addParameter('Parallel',false,@islogical);
    p.addParameter('BurnIn',0,@isnumeric);
    p.parse(varargin{:});
end
p=p.Results;

Nwalkers=size(minit,1);

if size(minit,2)*2>size(minit,1)
    warning('GWMCMC:minitdimensions','Check minit dimensions.\nIt is recommended that there be atleast twice as many walkers in the ensemble as there are model dimension.')
end

if p.ProgressBar
    progress=@textprogress;
else
    progress=@noaction;
end

Nkeep = Nsamples + p.BurnIn; % number of samples drawn per walker
models=nan(Nwalkers,M,Nkeep); % pre-allocate output matrix
models(:,:,1)=minit; % models: A WxMxT matrix, minit: A Mx(W*T) matrix

if ~iscell(logPfuns)
    logPfuns={logPfuns};
end

NPfun=numel(logPfuns);

%calculate logP state initial pos of walkers
logP=nan(Nwalkers,NPfun,Nkeep); %logP = WxPxT
for wix=1:Nwalkers
    for fix=1:NPfun
        v=logPfuns{fix}(minit(wix,:));
        if islogical(v) %reformulate function so that false=-inf for logical constraints.
            v=-1/v;logPfuns{fix}=@(m)-1/logPfuns{fix}(m); %experimental implementation of experimental feature
        end
        logP(wix,fix,1)=v;
    end
end

if ~all(all(isfinite(logP(:,:,1))))
    error('Starting points for all walkers must have finite logP')
end


reject=zeros(Nwalkers,1);

% models: A WxMxT matrix; logP: A WxPxT matrix
curm = models(:,:,1);  %curm: A WxM matrix
curlogP = logP(:,:,1); %curlogP: A WxP matrix
progress(0,0,0)
totcount=Nwalkers;
for row=1:Nkeep
    for jj=1:p.ThinChain
        %generate proposals for all walkers
        %(done outside walker loop, in order to be compatible with parfor - some penalty for memory):
        %-Note it appears to give a slight performance boost for non-parallel.
        rix=mod((1:Nwalkers)+floor(rand*(Nwalkers-1)),Nwalkers)+1; %pick a random partner
        zz=((p.StepSize - 1)*rand(Nwalkers,1) + 1).^2/p.StepSize;
        proposedm=curm(rix,:) - bsxfun(@times,(curm(rix,:)-curm),zz);
        logrand=log(rand(Nwalkers,NPfun+1)); %moved outside because rand is slow inside parfor
        if p.Parallel
            %parallel/non-parallel code is currently mirrored in
            %order to enable experimentation with separate optimization
            %techniques for each branch. Parallel is not really great yet.
            %TODO: use SPMD instead of parfor.

            parfor wix=1:Nwalkers
                cp=curlogP(wix,:);
                lr=logrand(wix,:);
                acceptfullstep=true;
                proposedlogP=nan(1,NPfun);
                if lr(1)<(numel(proposedm(wix,:))-1)*log(zz(wix))
                    for fix=1:NPfun
                        proposedlogP(fix)=logPfuns{fix}(proposedm(wix,:)); %have tested workerobjwrapper but that is slower.
                        if lr(fix+1)>proposedlogP(fix)-cp(fix) || ~isreal(proposedlogP(fix)) || isnan( proposedlogP(fix) )
                        %if ~(lr(fix+1)<proposedlogP(fix)-cp(fix))
                            acceptfullstep=false;
                            break
                        end
                    end
                else
                    acceptfullstep=false;
                end
                if acceptfullstep
                    curm(wix,:)=proposedm(wix,:); curlogP(wix,:)=proposedlogP;
                else
                    reject(wix)=reject(wix)+1;
                end
            end
        else %NON-PARALLEL
            for wix=1:Nwalkers
                acceptfullstep=true;
                proposedlogP=nan(1,NPfun);
                if logrand(wix,1)<(numel(proposedm(wix,:))-1)*log(zz(wix))
                    for fix=1:NPfun
                        proposedlogP(fix)=logPfuns{fix}(proposedm(wix,:));
                        if logrand(wix,fix+1)>proposedlogP(fix)-curlogP(wix,fix) || ~isreal(proposedlogP(fix)) || isnan(proposedlogP(fix))
                        %if ~(logrand(fix+1,wix)<proposedlogP(fix)-curlogP(fix,wix)) %inverted expression to ensure rejection of nan and imaginary logP's.
                            acceptfullstep=false;
                            break
                        end
                    end
                else
                    acceptfullstep=false;
                end
                if acceptfullstep
                    curm(wix,:)=proposedm(wix,:); curlogP(wix,:)=proposedlogP;
                else
                    reject(wix)=reject(wix)+1;
                end
            end

        end
        totcount=totcount+Nwalkers;
        progress((row-1+jj/p.ThinChain)/Nkeep,curm,sum(reject)/totcount)
    end
    models(:,:,row)=curm;
    logP(:,:,row)=curlogP;

    %progress bar

end
progress(1,0,0);
%fprintf('Acceptance rate of the sampler = %f\n', 1 - (sum(reject)/totcount));
acceptance_rate = 1 - (sum(reject)/totcount);

if p.BurnIn>0
    %crop=ceil(Nkeep*p.BurnIn);
    crop=p.BurnIn;
    models(:,:,1:crop)=[]; 
    logP(:,:,1:crop)=[];
    
%% Description of outputs:
    
output.samples = models;             % To show samples from the final posterior (TxMxW matrix)
output.acceptance = acceptance_rate; % To show the acceptance rate (scalar)
output.logProb = logP;               % To generate the logarithmic of probabilities for each sample (TxMxW matrix)

end

function textprogress(pct,curm,rejectpct)
persistent lastNchar lasttime starttime
if isempty(lastNchar)||pct==0
    lasttime=cputime-10;starttime=cputime;lastNchar=0;
    pct=1e-16;
end
if pct==1
    fprintf('%s',repmat(char(8),1,lastNchar));lastNchar=0;
    return
end
if (cputime-lasttime>0.1)

    ETA=datestr((cputime-starttime)*(1-pct)/(pct*60*60*24),13);
    progressmsg=[183-uint8((1:40)<=(pct*40)).*(183-'*') ''];
    curmtxt=sprintf('% 9.3g\n',curm(1:min(end,20),1));
    progressmsg=sprintf('\nGWMCMC %5.1f%% [%s] %s\n%3.0f%% rejected\n%s\n',pct*100,progressmsg,ETA,rejectpct*100,curmtxt);

    fprintf('%s%s',repmat(char(8),1,lastNchar),progressmsg);
    drawnow;lasttime=cputime;
    lastNchar=length(progressmsg);
end

function noaction(varargin)

% Acknowledgements: I became aware of the GW algorithm via a student report
% which was using emcee for python. Great stuff.
