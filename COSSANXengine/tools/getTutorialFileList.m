function Clist=getTutorialFileList
% This function returns a list of all the Tutorial matlab files present in
% OpenCossan
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

global OPENCOSSAN

Cfolderlist=OPENCOSSAN.CtutorialsPathFolders;

Clist=[];
for n = 1:length(Cfolderlist)    
    Clist=getSubList(fullfile(OPENCOSSAN.ScossanRoot,Cfolderlist{n}),Clist);
end

end

function Clist=getSubList(currentFolder,Clist)

     List=dir(currentFolder);
     List(1:2)=[];

     for n=1:length(List)
         if List(n).isdir
             SfolderPath=fullfile(currentFolder,List(n).name);
             Clist=getSubList(SfolderPath,Clist);
         else
             Clist{end+1}={fullfile(currentFolder,List(n).name)};
         end
     end
end 