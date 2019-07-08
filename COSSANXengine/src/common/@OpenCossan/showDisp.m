function showDisp(Xobj,Smessage,Nlevel)
%DISP Display array.
%   cossanDisp(X,NLevel) displays the array, without printing the array name if
%   Nlevel is greater then the verbose level set in the global variable
%   NverboseLevel.  
%   The message is printed using the built-in function disp
%
%   Verbose settings: 
%   0: ERROR/WARNING LEVEL
%       only error and warning are shown in the console
%   1; INFO LEVEL 
%       basic information are shown in the console
%   2: VERBOSE LEVEL
%       more  information are shown in the console
%   3: FULL LEVEL
%      very detailed information
%   4: DEBUG LEVEL
%      information useful for debugging 
%
%
% See Also: http://cossan.co.uk/wiki/index.php/@OpenCossan
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


if nargin==2
    Nlevel=1;
end

if Nlevel<=Xobj.NverboseLevel
   fprintf(Smessage)
   fprintf('\n')
end
