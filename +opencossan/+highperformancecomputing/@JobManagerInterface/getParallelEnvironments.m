function Cmembers = getParallelEnvironments( Xobj )
% GETPARALLELENVIRONMENTS
% Get the names of the available parallel environments

if strcmpi(Xobj.Stype,'gridengine')
    % this works only for SGE
    if ~OpenCossan.hasSSHConnection
        [status,SPElist] = system(Xobj.SqueryPE);
    else
        [status,SPElist] = OpenCossan.issueSSHcommand(Xobj.SqueryPE);
    end

    assert(status==0, 'openCOSSAN:JobManager', ...
        'Error retrieving parallel environment list from the job manager');

    Cmembers = regexpi(SPElist,'[\n]','split')'; % the transpose is done to be consistent with the output of the other methods
    if isempty(Cmembers{end}) 
        Cmembers(end)=[]; % remove the last empty entry
    end
else
    % Parallel environment are automatically enabled by LSF
    warning('openCOSSAN:JobManager:getParallelEnvironments', ...
        'No parallel environments are defined in LSF');
    Cmembers = {};
end

end

