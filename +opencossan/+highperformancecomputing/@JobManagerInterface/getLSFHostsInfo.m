function [Thosts, Cnames] = getLSFHostsInfo(Xobj)

% query the hosts of the cluster
if ~OpenCossan.hasSSHConnection
    [status,Sout] = system(Xobj.SqueryGrid);
else
    [status,Sout] = OpenCossan.issueSSHcommand(Xobj.SqueryGrid);
end

assert(status == 0, 'openCOSSAN:JobManagerInterface:getHosts',...
    'Error querying the cluster hosts.')

% process the output
% split at the new line
Clines=strsplit(Sout,'\n');

% find where the list of the proeprties of a queue begins
hostline = find(~cellfun(@isempty,strfind(Clines,'HOST  ')));

Cfieldnames = strsplit(Clines{hostline(1)+1});
Cfieldnames(strcmpi(Cfieldnames,'JL/U'))={'JL_U'}; % JL/U cannot be used as field name

Cfields = cell(length(hostline),length(Cfieldnames));
for ihost = 1:length(hostline)
    Cfields(ihost,:) = strsplit(Clines{hostline(ihost)+2});
end

Cnames = cell(length(hostline),1);
for ihost = 1:length(hostline)
    Cnames{ihost} = strtrim(strrep(Clines{hostline(ihost)},'HOST',''));
end

Cfields = [Cnames Cfields];
Cfieldnames = ['HOSTNAME' Cfieldnames];

Thosts = cell2struct(Cfields,Cfieldnames,2);
end