function Out = get(Xinput,varargin)
%GET  Get class random variable properties.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/get@Input
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Pierre Beaureparire

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'parametervalue'}
            if ~isempty(Xinput.Xparameters)
                Cparvar    = fieldnames(Xinput.Xparameters);
                for idv=1:length(Cparvar)
                    Out.(Cparvar{idv})     = Xinput.Xparameters.(Cparvar{idv}).value;
                end
                varargout{2}=[];
            else
                Out  = [];
            end
        case {'designvariablevalue'}
            if ~isempty(Xinput.XdesignVariable)
                Cdesvar    = fieldnames(Xinput.XdesignVariable);
                for idv=1:length(Cdesvar)
                    Out.(Cdesvar{idv})     = Xinput.XdesignVariable.(Cdesvar{idv}).value;
                end
                varargout{2}=[];
            else
                Out  = [];
            end
        case {'xfunctionvalue','functionvalue'}
            Out = cell2mat(Xinput.evaluateFunction);
        case {'defaultvalues'}
            Crvname     = Xinput.CnamesRandomVariable;
            Crvsetname  = Xinput.CnamesRandomVariableSet;
            Cbsetname   = Xinput.CnamesBoundedSet;
            Cspname     = Xinput.CnamesStochasticProcess;
            CnamesDesignVariable= Xinput.CnamesDesignVariable;
            Vmean       = zeros(1,length(Crvname));
            irv         = 0;
            Vdsvalue = zeros(1,length(Xinput.CnamesDesignVariable ));
            Vinvalue = zeros(1,length(Xinput.CnamesIntervalVariable ));
            
            
            for irvs=1:length(Crvsetname)
                Nrv                 = length(get(Xinput.Xrvset.(Crvsetname{irvs}),'members'));
                Vmean(irv+(1:Nrv))  = get(Xinput.Xrvset.(Crvsetname{irvs}),'mean');
                irv                 = irv+Nrv;
            end
            
            for i=1:length(CnamesDesignVariable)
                Vdsvalue(i) =  Xinput.XdesignVariable.(CnamesDesignVariable{i}).value;
            end
            
            Nin=0;
            for n=1:length(Cbsetname)
                for i=1:length(Xinput.Xbset.(Cbsetname{n}).CXint)
                    Vinvalue(i+Nin) = Xinput.Xbset.(Cbsetname{n}).CXint{i}.centre;
                end
                Nin=length(Xinput.Xbset.(Cbsetname{n}).CXint)+Nin;
            end
            
            for isp = 1:length(Cspname)
                if isp==1
                    Xds = Dataseries('Mdata',Xinput.Xsp.(Cspname{isp}).Vmean,...
                        'Mcoord',Xinput.Xsp.((Cspname{isp})).Mcoord,'Sindexname',Cspname{isp});
                else
                    Xds(1,isp) = Dataseries('Mdata',Xinput.Xsp.(Cspname{isp}).Vmean,...
                        'Mcoord',Xinput.Xsp.((Cspname{isp})).Mcoord,'Sindexname',Cspname{isp});
                end
            end
            % set mean values as sampled values
            if ~isempty(Crvsetname) && ~isempty(Cspname)
                Xinput.Xsamples     = Samples('CnamesStochasticProcess',Cspname,...
                'CnamesRandomVariableSet',Crvsetname,...
                'MsamplesPhysicalSpace',Vmean,'XDataseries',Xds,'Xinput',Xinput);
            end
            if isempty(Crvsetname) && ~isempty(Cspname)
                Xinput.Xsamples     = Samples('CnamesStochasticProcess',Cspname,...
                'XDataseries',Xds,'Xinput',Xinput);
            end
            if ~isempty(Crvsetname) && isempty(Cspname) && ~isempty(Xinput.CnamesDesignVariable)
                Xinput.Xsamples     = Samples('CnamesRandomVariableSet',Crvsetname,...
                'CnamesDesignVariables',CnamesDesignVariable,...
                'MsamplesPhysicalSpace',Vmean,'Msamplesdoedesignvariables',Vdsvalue,'Xinput',Xinput);
            end
            if ~isempty(Crvsetname) && isempty(Cspname) && ~isempty(Cbsetname)
                Xinput.Xsamples     = Samples('CnamesRandomVariableSet',Crvsetname,...
                'CnamesBoundedSet',Cbsetname,...
                'MsamplesPhysicalSpace',Vmean,'MsamplesEpistemicSpace',Vinvalue,'Xinput',Xinput);
            end
            if ~isempty(Crvsetname) && isempty(Cspname) && isempty(Xinput.CnamesDesignVariable) && isempty(Cbsetname)
                Xinput.Xsamples     = Samples('CnamesRandomVariableSet',Crvsetname,...
                'MsamplesPhysicalSpace',Vmean,'Xinput',Xinput);
            end
            if isempty(Crvsetname) && isempty(Cspname) && ~isempty(Xinput.CnamesDesignVariable) && isempty(Cbsetname)
                Xinput.Xsamples     = Samples('CnamesDesignVariables',CnamesDesignVariable,...
                'Msamplesdoedesignvariables',Vdsvalue,'Xinput',Xinput);
            end
            % Retrive values
            Out  = getStructure(Xinput);
            
        case {'xrv'}
            Crvset  = Xinput.CnamesRandomVariableSet;
            Out  = [];
            if ~isempty(Crvset)
                for irvs=1:length(Crvset)
                    Cmembers    = Xinput.Xrvset.(Crvset{irvs}).Cmembers;
                    index       = find(strcmp(Cmembers,varargin{2}));
                    if ~isempty(index)
                        Xrv     = get(Xinput.Xrvset.(Crvset{irvs}),'Xrv');
                        if ~isempty(Out)
                            warning('openCOSSAN:Input:get',...
                                ['The rv ' varargin{2} 'is present in more than 1 rvset']);
                        end
                        Out  = Xrv{index};
                    end
                end
            end
            
        otherwise
            error('openCOSSAN:Input:get','Required get (%s) features not implemented',varargin{k});
    end
end

if ~exist('Out','var')
    Out=[];
end

