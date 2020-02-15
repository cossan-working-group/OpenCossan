function Xev=add(Xev,varargin)
%ADD This method adds a worker object to the current Evaluator
%
% See also: https://cossan.co.uk/wiki/index.php/Add@Evaluator
%
% Author: Edoardo Patelli
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================
import opencossan.*

%% Process input argments
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'solver'
            assert(isa(varargin{k+1},'opencossan.workers.SolutionSequence'), ...
                'openCOSSAN:Evaluator', ...
                'The object of class %s is not valid after the PropertyName %s', ...
                class(varargin{k+1}),varargin{k})
            
            Xev.Solvers(end+1)=varargin{k+1};

        case {'shostname','cshostnames'}
            Xev.CShostnames{end+1}=varargin{k+1};
        case {'sparallelenvironment','spe','csparallelenviroments'}
            Xev.CSparallelEnvironments{end+1}=varargin{k+1};
        case {'squeue','csqueues'}
            Xev.CSqueues{end+1}=varargin{k+1};
        case {'sname','smember'}
            Xev.CSnames{end+1}=varargin{k+1};
        case {'nconcurrent'}
            Xev.Vconcurrent(end+1)=varargin{k+1};
        case {'nslots'}
            Xev.Vslots(end+1)=varargin{k+1};
        case {'xmember'}
            % The object are retrieved from the cell array
            if any(ismember(superclasses(varargin{k+1}),'opencossan.workers.Worker'))
                Xev.CXsolvers{end+1}=varargin{k+1};
                
            elseif any(ismember(superclasses(varargin{k+1}),'opencossan.metamodels.Metamodels'))
                Xev.CXsolvers{end+1}=varargin{k+1};
            elseif isa(varargin{k+1},'opencossan.highperformancecomputing.JobManagerInterface')
                Xev.XjobInterface=varargin{k+1};
            else
                error('openCOSSAN:Evaluator:add',...
                    'The object of class %s is not allowed',class(varargin{k+1}));
            end
            
        otherwise
            error('openCOSSAN:Evaluator',...
                'PropertyName %s is not  a valid PropertyName',varargin{k});
    end
end

% Validate object
Xev=validateObject(Xev);
