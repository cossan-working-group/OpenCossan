function cossanDisp(msg,level)
%cossanDisp Static Method to plot info on the console cossanDisp(msg,level)
% displays the array, without printing the array name if level is greater
% then the verbose level set in OpenCossan, the message is printed using
% the built-in function disp.
%
%   Verbose settings:
%   0: ERROR/WARNING LEVEL
%       only error and warning are shown in the console
%   1: INFO LEVEL
%       basic information are shown in the console
%   2: VERBOSE LEVEL
%       more  information are shown in the console
%   3: FULL LEVEL
%      very detailed information
%   4: DEBUG LEVEL
%      information useful for debugging

%{
This file is part of OpenCossan <https://cossan.co.uk>.
Copyright (C) 2006-2018 COSSAN WORKING GROUP

OpenCossan is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License or,
(at your option) any later version.

OpenCossan is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

if nargin == 0
    return;
end

if nargin == 1
    level = 1;
end

validateattributes(msg,{'char' 'string' 'cell'},{});

if level <= opencossan.OpenCossan.getInstance().VerboseLevel
    if isa(msg,'char') || isa(msg,'string')
        fprintf('%s\n',msg)
    else
        for n=1:length(msg)
            if isa(msg{n},'char') || isa(msg{n},'string')
                fprintf('%s\n',msg{n})
            end
        end
    end
end
end
