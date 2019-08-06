function varargout=plotConstraint(Xobj,varargin)
% PLOTCONSTRAINT This method plots the evolution of the constraints
%
% Check that some constraints exist
if Xobj.XOptimizationProblem.Nconstraints==0
    opencossan.OpenCossan.cossanDisp('No contraints present in the Optimum object, nothing to show :(',1)
    return
end


% Check name of the Contraints
Cnames=[];
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'cnames'
            Cnames=varargin{k+1};
        case 'sname'
            Cnames=varargin(k+1);
    end
end

if isempty(Cnames)
    varargin{end+1}='Cnames';
    varargin{end+1}=Xobj.CconstraintsNames;
else
    assert(all(ismember(Cnames,Xobj.CconstraintsNames)),...
    'Optimum:plotDesignVaraible',...
    ['Contraint Name(s) not available\n', ...
    'Required variables: %s \nAvailable variables: %s'],...
    sprintf('"%s" ',Cnames{:}),sprintf('"%s" ',Xobj.CconstraintsNames{:}))
end

%% Prepare variables
varargin{end+1}='VXdata';
varargin{end+1}=Xobj.TablesValues.Iteration;

varargin{end+1}='MYdata';
varargin{end+1}=Xobj.TablesValues.Constraints;

varargin{end+1}='Sylabel';
varargin{end+1}='Constraint';

% Plot figure
varargout{:}=plotOptimum(Xobj,varargin{:});

end