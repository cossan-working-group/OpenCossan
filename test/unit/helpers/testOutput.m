function [works] = testOutput(obj,phrase)
%TESTOUTPUT Tests if the display of an object
%
%   TESTOUTPUT(OBJ,PHRASE) tests if the displaymethod for a certain object
%   obj shows the data defined in phrase.

% This file is part of *OpenCossan*: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% *OpenCossan* is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

% Initialize output and set verbosity level
works = false;
global OPENCOSSAN
OPENCOSSAN.VerboseLevel = 3;

% Make tamporary file
fileID = fopen('dispTest.txt', 'w+');

% Start diary and call disp-function of object
diary('dispTest.txt');
obj.disp;
diary off;

% Read from teporary file using textscan
checkString = textscan(fileID, '%s', 10 ,'Delimiter','\n');

% check if phrase is included in output
for i = 1:length(phrase)
    incl = strfind(checkString{1,1},phrase(i));
    index = find(~cellfun(@isempty,incl),1);
    if ~isempty(index)
        works = true;
    else
        works = false;
    end
end

% delete temporary file and reset verbosity level
fclose(fileID);
delete dispTest.txt
OPENCOSSAN.VerboseLevel = 0;
end

