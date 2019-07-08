function XSimOut = minus(XSimOut1,XSimOut2)
%MINUS substracts XSimOut2 from XSimOut1
%
%
%  Usage: MINUS(XSimOut1,XSimOut2) substracts the Output object XSimOut2
%  from XSimOut1
%  Example:  minus(XSimOut1,XSimOut2)
%
% Copyright 2006-2017 COSSAN Working Group,
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


Vindex = isfield(XSimOut1.Tvalues,XSimOut2.Cnames);
if ~all(Vindex)==1
    error('openCOSSAN:SimulationData:minus',...
        'the two objects do not contain the same output variables');
end

if XSimOut1.Nsamples ~= XSimOut2.Nsamples
    error('openCOSSAN:SimulationData:minus',...
        'the two objects do not contain the same number of simulations');
end

% Initialize structure
Cdiff=struct2cell(XSimOut1.Tvalues);
C2=struct2cell(XSimOut2.Tvalues);

for i=1:length(Cdiff)
    Cdiff{i}=Cdiff{i}-C2{i};
end

Tvalues = cell2struct(Cdiff, XSimOut1.Cnames, 1);        
XSimOut = SimulationData('Tvalues',Tvalues);

end

