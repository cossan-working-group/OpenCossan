function Out = get(Xobj,PropertyName,varargin)
%GET  Return the required propertiy or quantity from the input object.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/get@Input
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Pierre Beaureparire

import opencossan.common.Samples
import opencossan.common.Dataseries

allowableProperties = {'ParameterValues','DesignVariableValues','FunctionValues',...
    'DefaultValues','RandomVariable'};

assert(ismember(PropertyName,allowableProperties),'openCOSSAN:Input:get',...
    'GET of (%s) features not implemented',PropertyName)

switch lower(PropertyName)
    case {'parametervalues'}
        if ~Xobj.Nparameters == 0
            Cparvar    = Xobj.ParameterNames;
            for ipar=1:length(Cparvar)
                Out.(Cparvar{ipar})     = Xobj.Parameters.(Cparvar{ipar}).Value;
            end
            varargout{2}=[];
        else
            Out  = [];
        end
    case {'designvariablevalues'}
        if ~Xobj.NdesignVariables == 0
            Cdesvar    = (Xobj.DesignVariableNames);
            for idv=1:length(Cdesvar)
                Out.(Cdesvar{idv}) = Xobj.DesignVariables.(Cdesvar{idv}).Value;
            end
            varargout{2}=[];
        else
            Out  = [];
        end
    case {'functionvalues'}
        if ~Xobj.Nfunctions==0
            if nargin < 3
                Out = cell2mat(Xobj.evaluateFunction);
            else
                Out = cell2mat(Xobj.evaluateFunction('Name',varargin{1}));
            end
        end
    case {'defaultvalues'}
        Crvname     = Xobj.RandomVariableNames;
        Crvsetname  = Xobj.RandomVariableSetNames;
        %             Civsetname   = Xinput.CnamesBoundedSet;
        Cspname     = Xobj.StochasticProcessNames;
        CnamesDesignVariable= Xobj.DesignVariableNames;
        Vmean       = zeros(1,length(Crvname));
        irv         = 0;
        Vdsvalue = zeros(1,length(Xobj.DesignVariableNames ));
        %             Vinvalue = zeros(1,length(Xinput.CnamesIntervalVariable ));
        
        for irvs=1:length(Crvsetname)
            Nrv = numel(Xobj.RandomVariableSets.(Crvsetname{irvs}).Members);
            Vmean(irv+(1:Nrv)) = Xobj.RandomVariableSets.(Crvsetname{irvs}).getMean();
            irv = irv+Nrv;
        end
        
        for i=1:length(CnamesDesignVariable)
            Vdsvalue(i) = Xobj.DesignVariables.(CnamesDesignVariable{i}).Value;
        end
        
        %            Niv=0;
        %             for n=1:length(Civsetname)
        %                 for i=1:length(Xinput.Xivset.(Civsetname{n}).Xvar)
        %                     Vinvalue(i+Niv) = Xinput.Xivset.(Civsetname{n}).Xvar{i}.centre;
        %                 end
        %                 Niv=length(Xinput.Xivset.(Civsetname{n}).Xvar)+Niv;
        %             end
        
        for isp = 1:length(Cspname)
            if isp==1
                Xds = Dataseries('Mdata',Xobj.StochasticProcesses.(Cspname{isp}).Mean,...
                    'Mcoord',Xobj.StochasticProcesses.((Cspname{isp})).Coordinates,'Sindexname',Cspname{isp});
            else
                Xds(1,isp) = Dataseries('Mdata',Xobj.StochasticProcesses.(Cspname{isp}).Mean,...
                    'Mcoord',Xobj.StochasticProcesses.((Cspname{isp})).Coordinates,'Sindexname',Cspname{isp});
            end
        end
        % set mean values as sampled values
        
        % TODO: This code should definietely be improved
        Xobj.Samples=[];
        if ~isempty(Crvsetname) && ~isempty(Cspname)
            Xobj.Samples     = Samples('CnamesStochasticProcess',Cspname,...
                'CnamesRandomVariableSet',Crvsetname,...
                'MsamplesPhysicalSpace',Vmean,'XDataseries',Xds,'Xinput',Xobj);
        end
        %             if ~isempty(Crvsetname) && ~isempty(Cspname) && ~isempty(Civsetname)
        %                 Xinput.Samples     = Samples('CnamesStochasticProcess',Cspname,...
        %                 'CnamesRandomVariableSet',Crvsetname,'CnamesBoundedSet',Civsetname,...
        %                 'MsamplesPhysicalSpace',[Vmean,Vinvalue],'XDataseries',Xds,'Xinput',Xinput);
        %             end
        if isempty(Crvsetname) && ~isempty(Cspname)
            Xobj.Samples     = Samples('CnamesStochasticProcess',Cspname,...
                'XDataseries',Xds,'Xinput',Xobj);
        end
        %             if isempty(Crvsetname) && ~isempty(Cspname) && ~isempty(Civsetname)
        %                 Xinput.Samples     = Samples('CnamesStochasticProcess',Cspname,...
        %                     'CnamesBoundedSet',Civsetname,'MsamplesPhysicalSpace',Vinvalue,...
        %                     'XDataseries',Xds,'Xinput',Xinput);
        %             end
        if ~isempty(Crvsetname) && isempty(Cspname) && ~isempty(CnamesDesignVariable)
            Xobj.Samples     = Samples('CnamesRandomVariableSet',Crvsetname,...
                'CnamesDesignVariables',CnamesDesignVariable,...
                'MsamplesPhysicalSpace',Vmean,'Msamplesdoedesignvariables',Vdsvalue,'Xinput',Xobj);
        end
        %             if ~isempty(Crvsetname) && isempty(Cspname) && ~isempty(CnamesDesignVariable) && ~isempty(Civsetname)
        %                 Xinput.Samples     = Samples('CnamesRandomVariableSet',Crvsetname,...
        %                 'CnamesDesignVariables',CnamesDesignVariable,'CnamesBoundedSet',Civsetname,...
        %                 'MsamplesPhysicalSpace',[Vmean,Vinvalue],'Msamplesdoedesignvariables',Vdsvalue,'Xinput',Xinput);
        %             end
        %             if ~isempty(Crvsetname) && isempty(Cspname) && ~isempty(Civsetname)
        %                 Xinput.Samples     = Samples('CnamesRandomVariableSet',Crvsetname,...
        %                 'CnamesBoundedSet',Civsetname,...
        %                 'MsamplesPhysicalSpace',[Vmean,Vinvalue],'Xinput',Xinput);
        %             end
        if ~isempty(Crvsetname) && isempty(Cspname) && isempty(CnamesDesignVariable)
            Xobj.Samples     = Samples('CnamesRandomVariableSet',Crvsetname,...
                'MsamplesPhysicalSpace',Vmean,'Xinput',Xobj);
        end
        if isempty(Crvsetname) && isempty(Cspname) && ~isempty(CnamesDesignVariable)
            Xobj.Samples     = Samples('CnamesDesignVariables',CnamesDesignVariable,...
                'Msamplesdoedesignvariables',Vdsvalue,'Xinput',Xobj);
        end
        %             if isempty(Crvsetname) && isempty(Cspname) && isempty(CnamesDesignVariable) && ~isempty(Civsetname)
        %                 Xinput.Samples     = Samples('CnamesIntervalVariableSet',Civsetname,...
        %                     'MsamplesPhysicalSpace',Vinvalue,'Xinput',Xinput);
        %             end
        
        
        
        
        % Retrieve values
        Out  = getStructure(Xobj);
        
    case {'randomvariable'}
        assert(nargin==3,'opencossan:Input:get:RandomVariable','RandomVariable name not specified')
        Crvset  = Xobj.RandomVariableSetNames;
        Out  = [];
        if ~isempty(Crvset)
            for irvs=1:length(Crvset)
                Cmembers    = Xobj.RandomVariableSets.(Crvset{irvs}).Cmembers;
                index       = find(strcmp(Cmembers,varargin{1}));
                if ~isempty(index)
                    Xrv     = get(Xobj.RandomVariableSets.(Crvset{irvs}),'Xrv');
                    if ~isempty(Out)
                        warning('openCOSSAN:Input:get',...
                            ['The rv ' varargin{1} 'is present in more than 1 rvset']);
                    end
                    Out  = Xrv{index};
                end
            end
        end
        %         case {'xbv'} % TODO: SILVIA: Controlla per usare intervalli invece che bset
        %             Cconvexset  = Xinput.CnamesConvexSet;
        %             Out  = [];
        %             if ~isempty(Cconvexset)
        %                 for ics=1:length(Cconvexset)
        %                     Cmembers    = Xinput.Xcset.(Cconvexset{ics}).Cmembers;
        %                     index       = find(strcmp(Cmembers,varargin{2}));
        %                     if ~isempty(index)
        %                         Xbv     = get(Xinput.Xcset.(Cconvexset{ics}),'Xbv');
        %                         if ~isempty(Out)
        %                             warning('openCOSSAN:Input:get',...
        %                                 ['The bv ' varargin{2} 'is present in more than 1 convexset']);
        %                         end
        %                         Out  = Xbv{index};
        %                     end
        %                 end
        %             end
        
    otherwise
        error('openCOSSAN:Input:get','GET of (%s) features not implemented',PropertyName);
end


if ~exist('Out','var')
    Out=[];
end

