function [varargout] =pf(Xsys,varargin)
% PF this method is used to estimate the failure probability of each basic
% events or the failure probability of an arbitrary cut-set.
% The method returns a CutSet object
%
% Valid PropertyNames
% * VcutsetIndex = Vector of the index of the events that form the cutset
% * Xsimulations = Simulation Object that specify the simulation analyis
% Output Arguments
% Xcutset:      CutSet object
% varargout{1}: Simulation output
%
% Usage:
% Xcs=Xsys.pf('VcutsetIndex',[1 3])
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/pf@SystemReliability
%
% Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
% Author: Edoardo-Patelli

%% Process inputs arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case ('ccutset')
            % User define cut set
            Cmcs=varargin{k+1};
        case ('vcutsetindex')
            % User define cut set
            Cmcs=varargin(k+1);
        case {'xsimulation','xsimulations'}
            Xsimulator=varargin{k+1};
        case 'cxsimulation'
            Xsimulator=varargin{k+1}{1};
        otherwise
            error('openCOSSAN:SystemReliabiliy:pf',...
                '%s is not a valid PropertyName',varargin{k})
    end
end

%% Check inputs

assert(logical(exist('Xsimulator','var')),...
    'openCOSSAN:SystemReliabiliy:pf',...
    'it is mandatory to provide a Simulation object')


%% Evaluate the Model
% the model should be evaluated on once since usually is the part
% invoving the 3rd-party software. Then, we can evaluate the
% individual limit state function

XsimOut=Xsimulator.apply(Xsys.Xmodel);

% store the name of the batch folder
SbatchFolder=XsimOut.SbatchFolder;

if ~exist('Cmcs','var')
    Cmcs=getMinimalCutSets(Xsys);
end

%% Loop over the cut-sets
for ics=1:length(Cmcs)
    Vindex=Cmcs{ics};
    
    %% Compute the failure probability
    VindicatorFunctionToT=[]; % indicator function for all the batches
    
    
    
    for ib=1:Xsimulator.Nbatches
        % Now we use the SimulationData to evaluate all the performance
        % function defined in Vindex (i.e. only the performance function
        % actually involved in the cut set)
        
        
        % Name of the simulation object
        if ib==Xsimulator.Nbatches
            [~, Vg]=Xsys.XperformanceFunctions(Vindex(1)).apply(XsimOut);
        else
            Sfilename=fullfile(SbatchFolder,[Xsimulator.SbatchFileNames num2str(ib) '_of_' num2str(Xsimulator.Nbatches)]);
            XsimOut=SimulationData.load('Sfilename',Sfilename);
            [~, Vg]=Xsys.XperformanceFunctions(Vindex(1)).apply(XsimOut);
        end
        
        VindicatorFunction=logical(Vg<=0); % Vector of indices
        VposIS=find(Vg<=0);
        
        %  In order to speed-up the analysis only the samples in the
        %  failure region are re-evaluated. Please remember that a cut set
        %  is by definition defined as the combination of events (parallel
        %  system)
        
        % Now reuse the same samples to estimate the pf of the cut-set
        for imcs=2:length(Vindex)
            
            if isempty(VposIS)
                % Exit from the loop if there are no samples in the failure
                % area to be evaluated
                break
            end
            
            % A simulation object containing only the samples in the failure
            % region is created.
            XsimFail=XsimOut.split('Vindices',VposIS);
            
            [~, Vg]=Xsys.XperformanceFunctions(Vindex(imcs)).apply(XsimFail);
            VindicatorFunction(VposIS(Vg>0))=0;
            % remove samples not in the failure
            VposIS(Vg>0)=[];
        end
        
        switch class(Xsimulator)
            case {'MonteCarlo','LatinHypecubeSampling','HaltonSampling','SobolSampling'}
                %% Compute the pf and CoV for each batch
                pfhat=sum(VindicatorFunction)/XsimOut.Nsamples;
                cov=sqrt( (1-pfhat)/ (XsimOut.Nsamples*pfhat));
                
                variancePf=(cov*pfhat)^2;
                
                %% Update the FailureProbability object
                if ib==1
                    % Initialize FailureProbability
                    Xobj.XfailureProbability(ics)=FailureProbability('Smethod',class(Xsimulator), ...
                        'pf',pfhat,'variancepf',variancePf,'Nsamples',XsimOut.Nsamples);
                else
                    Xobj.XfailureProbability(ics)=Xobj.XfailureProbability(ics).addBatch ...
                        ('pf',pfhat,'variancepf',variancePf,'Nsamples',XsimOut.Nsamples);
                end
            case {'ImportanceSampling'}
               Vweights=XsimOut.getValues('Sname','Vweigths');
               pfhat=sum(Vweights(VindicatorFunction))/XsimOut.Nsamples;
               
              variancePf = var(Vweights(VindicatorFunction))/XsimOut.Nsamples;
                %% Update the FailureProbability object
                if ib==1
                    % Initialize FailureProbability
                    Xobj.XfailureProbability(ics)=FailureProbability('Smethod',class(Xsimulator), ...
                        'pf',pfhat,'variancepf',variancePf,'Nsamples',XsimOut.Nsamples,...
                        'SweigthsName','Vweigths');
                else
                    Xobj.XfailureProbability(ics)=Xobj.XfailureProbability(ics).addBatch ...
                        ('pf',pfhat,'variancepf',variancePf,'Nsamples',XsimOut.Nsamples,...
                        'SweigthsName','Vweigths');
                end
                
            otherwise
                 error('openCOSSAN:SystemReliabiliy:pf',...
                'Simulation %s method not available in SystemReliability',class(Xsimulator))
        end
    end
    
end

% switch class(Xsimulator)
%
%     case {'IS'}
%
%         if isempty(Xsimulation)
%             Define the Simulation object
%             Use the Design point of each component separately.
%             NsamplesSingle=floor(Nsamples/length(Xsys.XdesignPoints));
%
%             Construct the first ImportanceSampling object
%             Xsimulation=ImportanceSampling('Nsamples',NsamplesSingle, ...
%                 'Nbatches',Nbatches,'DesignPoint',Xsys.XdesignPoints{1});
%             for idp=2:length(Xsys.XdesignPoints)
%                 if idp==length(Xsys.XdesignPoints)
%                     NsamplesSingle=NsamplesSingle+rem(Nsamples,length(Xsys.XdesignPoints));
%                 end
%                 Xsimulation(idp)=ImportanceSampling('Nsamples',NsamplesSingle,...
%                     'Nbatches',Nbatches,'DesignPoint',Xsys.XdesignPoints{idp}); %#ok<AGROW>
%             end
%         end
%
%         if Lbasicevent
%             error('openCOSSAN:reliability:SystemReliabiliy:pf',...
%                 'Method not implemented')
%         else
%
%             if Nbatches>1
%                 error('openCOSSAN:reliability:SystemReliabiliy:pf',...
%                     'Support of multiple batches not implemented yet')
%             end
%             % Evaluate the Model
%             the model should be evaluated on once since usually is the part
%             invoving the 3rd-party softwar. Then, we can evaluate the
%             individual limit state function
%
%
%             TODO: extend for more Models
%             XsimOut=Xsimulation(1).apply('Xtarget',Xsys.Xmodel);
%
%             Add others Simulation object
%             for is=2:length(Xsimulation)
%                 Xsimtmp=Xsimulation(is).apply('Xtarget',Xsys.Xmodel);
%                 XsimOut=XsimOut.merge(Xsimtmp);
%             end
%
%             Now we use the SimulationData to evaluate all the performance
%             function defined in Vpos (i.e. only the performance function
%             actually involved in the cut set)
%
%             [Xdummy Vg]=Xsys.XperformanceFunctions(Vpos(1)).apply(XsimOut);
%
%              In order to speed-up the analysis only the samples in the
%              failure region are re-evaluated. Please remember that a cut set
%              is by definition defined as the combination of events (parallel system)
%
%             VindicatorFunction=logical(Vg<=0); % Vector of indices
%             VposIS=find(Vg<=0);
%
%
%
%
%             Now reuse the same samples to estimate the pf of the cut-set
%             for imcs=2:length(Vpos)
%
%                 if isempty(VposIS)
%                     Exit from the loop if there are no samples to be
%                     evaluated
%                     break
%                 end
%
%                 A simulation object containing only the samples in the failure
%                 region is created.
%                 XsimFail=XsimOut.split('Vindices',VposIS);
%
%                 [Xdummy Vg]=Xsys.XperformanceFunctions(Vpos(imcs)).apply(XsimFail);
%                 VindicatorFunction(VposIS(Vg>0))=0;
%                 remove samples not in the failure
%                 VposIS(Vg>0)=[];
%
%             end
%             Vweights=XsimOut.getValues('Sname','Vweigths');
%             pfhat=sum(Vweights(VindicatorFunction))/Nsamples;
%
%             varpfhat = var(Vweights(VindicatorFunction))/Nsamples;
%             CoV = sqrt(varpfhat) /pfhat;
%
%             Tpf = struct('Stype','IS','pfhat', pfhat,'CoV',CoV,'Nsamples',Nsamples);
%
%         end
%         XsimOut=XsimFail;
%
%     case {'HPIS'}
%         if Lbasicevent
%             error('openCOSSAN:reliability:SystemReliabiliy:pf',...
%                 'Method not implemented')
%         else
%             %
%             find dp of intersection (the user defined cut sets)
%
%             [Xo, Tpf]=HPIS(Xsys,'Nsamples',Nsamples,'Vmembers',Vpos);
%             [Xo, Tpf]=HPIS(Xsys,'Nsamples',Nsamples,'Vmembers',Vpos);
%
%
%                         Vg=get(Xo,'performancefunction');
%                         if isempty(Vg)
%                             Vg=Moutput;
%                         end
%
%                         % Now reuse the same samples to estimate the pf of the cut-set
%                         for imcs=3:length(Vpos)
%                             Tinput=Tinput(Vg<0);
%                             Vweights=Vweights(Vg<0);
%                             if isempty(Tinput)
%                                 break
%                             end
%                             Xprobmodel=Xsys.Xmembers{Vpos(imcs)};
%                             Vg=apply(get(Xprobmodel,'Xg'),Tinput);
%                         end
%                         pfhat=sum(Vweights(Vg<0))/Nsamples;
%                         varpfhat = var(Vweights(Vg<0)) / Nsamples;
%                         CoV = sqrt(varpfhat) /pfhat;
%                         Tpf = struct('Stype','HPIS','pfhat', pfhat,'CoV',CoV);
%             pfhat=Tpf.pfhat;
%             XsimOut=Xo;
%         end
%
%     case {'FORM'}
%         for idp=1:length(Xsys.XdesignPoints)
%             Vpfhat(idp)=Xsys.XdesignPoints{idp}.NReliabilityIndex;
%             Tpf(idp) = struct('Stype','FORM','pfhat', Vpfhat(idp));
%         end
%         pfhat=Vpfhat;
%         XsimOut=[];
%     otherwise
%         error('openCOSSAN:reliability:SystemReliabiliy:pf','Method not implemented')
%
% end


%% EXPORT Results

varargout{1}=Xobj.XfailureProbability;

if nargout>1
    for n=1:length(Cmcs)
        Xcutset(n)=Xsys.getCutset('Vcutsetindex',Cmcs{n},...
            'XfailureProbability',Xobj.XfailureProbability(n)); %#ok<AGROW>
    end
    varargout{2}=Xcutset;
    varargout{3}=XsimOut;
end
