function varargout = getMembers(Xfun)
%   getMembers This function allows retrieving the names of all objects
%   that are associated with the object Xfun as well as the type of objects
%   associated
%
%
%   MANDATORY ARGUMENTS:
%
%   - Xfun      : Function object
%
%   OPTIONAL ARGUMENTS:
%
%
%   OUTPUT:
%
%   - varargout(1)  : cell containing name of each object
%   - varargout(2)  : cell containing the type of object
%
%
%   EXAMPLE:
%
%   [Cmembers Ctypes] = getMembers(Xfun)
%
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

Ctokens = Xfun.Ctoken;
for i=1:length(Ctokens)
    Ctokens{i} = Ctokens{i}{1};
end

Cmems = {};
Ctype = {};

for i=1:length(Ctokens)
    Tv = evalin('base',['whos(' '''' Ctokens{i} '''' ') ']);
    
    if isempty(Tv)
        Tv = evalin('caller',['whos(' '''' Ctokens{i} '''' ') ']);
    end
    
    
    
    if isempty(Tv)
        warning('openCOSSAN:Function:getMembers',...
            ['The object named ('  Ctokens{i} ') was not found in base workspace']);
        break;
    end
    
    if strcmpi(Tv.class,'Function')
        % recursively ask for members of Function
        Cmems = [Cmems; Tv.name];
        Ctype = [Ctype; Tv.class];
        [Cmems_part, Ctype_part] = evalin('base', [Ctokens{i} '.getMembers;']);
        Cmems = [Cmems; Cmems_part(:)]; %#ok<*AGROW>
        Ctype = [Ctype; Ctype_part(:)];
    else
        Cmems = [Cmems; Tv.name];
        Ctype = [Ctype; Tv.class];
    end
end

varargout{1} = Cmems;
varargout{2} = Ctype;
end