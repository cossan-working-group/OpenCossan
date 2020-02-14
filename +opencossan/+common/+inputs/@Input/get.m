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
        if Xobj.NumberOfDesignVariables ~= 0
            dvs = Xobj.DesignVariables;
            names = Xobj.DesignVariableNames;
            for i = 1:length(dvs)
                Out.(names(i)) = dvs(i).Value;
            end
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

