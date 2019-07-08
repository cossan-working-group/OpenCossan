function Xobj = add(Xobj,varargin)
%ADD method adding data to a LineSamplingOutput object
%
%   OPTIONAL ARGUMENTS:
%   ====================
%   - VnumPointLine: array containing the number of points on each line
%
%   OUTPUT ARGUMENT:
%   ====================
%   Xrv: LineSamplingOutput object
%
%
%   USAGE
%   ====================
%   Xobj  =add(Xobj,'vnumpointline' ,[2 3 4 5]')
    


for k=1:2:length(varargin)
    switch lower(varargin{k})
        
        case {'vnumpointline'}
            % the field SoutputName is always a vector column
            if size(varargin{k+1},2) ~= 1 && size(varargin{k+1},1)
                error('openCOSSAN:SimulationData:add',...
                    'The number of point on each line must be a vector');
            end
            if size(varargin{k+1},2) ~= 1
                Xobj.VnumPointLine =[ Xobj.VnumPointLine; varargin{k+1}'];
            else
                Xobj.VnumPointLine = [ Xobj.VnumPointLine; varargin{k+1}];
            end
        otherwise
            error('openCOSSAN:SimulationData:SimulationData',...
                'Field name not allowed');

    end
                

    
end %for k

end

