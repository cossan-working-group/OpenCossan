function [TableOutput, Mout]= getStatistics(Xobj,varargin)
%GETSTATISTICS Compute the statistics of the variables present in the
%           SimulationData Object
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getStatistics@SimulationData
%
% Copyright 1983-2015 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli
%
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

%% Validate input arguments


%% Process input arguments
Cnames=Xobj.Cnames;

for k=1:2:nargin-1,
    switch lower(varargin{k})
        case 'sname'
            %check input
            Cnames = varargin(k+1);
        case {'cnames','csname'}
            %check input
            Cnames = varargin{k+1};
        otherwise
            error('openCOSSAN:outputs:SimulationData:getStatistics', ...
                'PropertyName %s not valid',varargin{k})
    end
end

assert(all(ismember(Cnames,Xobj.Cnames)),...
    'openCOSSAN:outputs:SimulationData:getStatistics', ...
    'Variable(s) not present in the SimulationData object!\n Required variables: %s\nAvailable variables: %s',...
    sprintf('"%s" ',Cnames{:}),sprintf('"%s" ',Xobj.Cnames{:}))

Vfield=ismember(Xobj.Cnames,Cnames);


Mout=table2array(Xobj.TableValues(:,Vfield));

%% Compute the statistics for the required variables
% Initialize output
Mstats=zeros(5,length(Cnames));

for n=1:length(Cnames)
    % Find the min
    Mstats(1,n) = min(Mout(:,n));
    
    % Find the max
    Mstats(2,n)  = max(Mout(:,n));
    
    % Find the mean
    Mstats(3,n)  = nanmean(Mout(:,n));
    
    % Find the median
    Mstats(4,n)  = nanmedian(Mout(:,n));
    
    % Find the std
    Mstats(5,n)  = nanstd(Mout(:,n));
end

TableOutput = array2table(Mstats,'RowNames',{'Minimum','Maximum','Mean','Median','Standar Deviation'},'VariableNames',Cnames);





