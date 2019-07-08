function [MphysicalSpace MsamplesDV] = hypercube2physical(Xinput,MsamplesHypercube)

Nrv = Xinput.NrandomVariables;
Ndv = Xinput.NdesignVariables;
Nsp = Xinput.NstochasticProcesses;
Nsamples = size(MsamplesHypercube,1);
Cset=Xinput.CnamesSet;
Cgrvs=Xinput.CnamesGaussianMixtureRandomVariableSet;
Cdv = Xinput.CnamesDesignVariable;

assert(size(MsamplesHypercube,2)==Nrv+length(Cgrvs)+Ndv,...
    'openCOSSAN:Input:hypercube2physical',...
    ['The number of columns of the hypercube matrix (%d) is smaller ',...
    'than the required number of columns (%d)\n',...
    'Required columns:\n - Nr. of total random variables: %d\n',...
    ' - Nr. of Gaussian mixture random variable sets: %d\n',...
    ' - Nr. of design variables: %d'],size(MsamplesHypercube,2),...
    Nrv+length(Cgrvs)+Ndv,Nrv,length(Cgrvs),Ndv);

% initialize counters
irv=0;
igmrvset=0;
if Nrv~=0
    %% Map the sample from the UNCORRELATED hypercube to physical space
    MphysicalSpace=zeros(Nsamples,Nrv);
    
    % Map samples for the RandomVariableSet
    for n=1:length(Cset)
        Nrv=Xinput.Xrvset.(Cset{n}).Nrv;
        if isa(Xinput.Xrvset.(Cset{n}),'RandomVariableSet')
            MsamplesSNS=norminv(MsamplesHypercube(:,irv+igmrvset+(1:Nrv)));
            MphysicalSpace(:,irv+(1:Nrv))= ...
                Xinput.Xrvset.(Cset{n}).map2physical(MsamplesSNS);
        elseif isa(Xinput.Xrvset.(Cset{n}),'GaussianMixtureRandomVariableSet')
            % Map samples for the GaussianMixtureRandomVariableSet
            MphysicalSpace(:,irv+(1:Nrv))= ...
                Xinput.Xrvset.(Cset{n}).uncorrelatedCDF2PhysicalSpace(MsamplesHypercube(:,irv+igmrvset+(1:Nrv+1)));
            % Update Counter variable
            igmrvset=igmrvset+1;
        else
            error('openCOSSAN:LatinHypercubeSampling:sample', ...
                ['Object of class ' class(Xinput.Xrvset.(Cset{n})) ' not allowed' ])
        end
        irv=irv+Nrv;
    end
else
    MphysicalSpace=[];
end

if Ndv~=0
    %% Map samples for the design variables. The samples of the dv are
    % assumed to be generated uniformly.
    MsamplesDV = zeros(Nsamples,Ndv);
    for n=1:Ndv
        assert(~isinf(Xinput.XdesignVariable.(Cdv{n}).lowerBound) && ...
            ~isinf(Xinput.XdesignVariable.(Cdv{n}).upperBound),...
            'openCOSSAN:LatinHypercubeSampling:sample',...
            'Only continuos design variables with finite support can be used with Latin Hypercube sampling')
        MsamplesDV(:,n)=Xinput.XdesignVariable.(Cdv{n}).lowerBound + ...
            (Xinput.XdesignVariable.(Cdv{n}).upperBound - Xinput.XdesignVariable.(Cdv{n}).lowerBound)*MsamplesHypercube(:,irv+igmrvset+n);
    end
else
    MsamplesDV=[];
end

if Nsp~=0
    %% TODO: implement sampling of stochastic process with imposed rv values from quasi-MC methods
end

end