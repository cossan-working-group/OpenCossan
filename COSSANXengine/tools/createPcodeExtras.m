function createPcodeExtras(SinputPath)
%% OpenCOSSAN build function
% This function require the full path of the folder containing the matlab
% source code. The p-code are created in the toolbox extras 
%
% Created by MB
% Updated by Edoardo Patelli
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



assert(nargin==1,'openCOSSAN:createPcode', ...
    'The fullpath of the source folderif required')

Spwd=pwd;

%SinputPath=[OpenCossan.getCossanRoot filesep 'src'];

disp(['Cossan source folder: ' SinputPath])

SdistPath=fullfile(OpenCossan.getCossanRoot,'src','extras');

disp(['Creating COSSANengine pcode in the foder: ' SdistPath])

disp('Creating destination folder...')

%% create the target directory
if isdir(SdistPath)
   disp('Directory already exist in target folder, skipping...')
else
   disp('Creating target folder, ...')
   [~, Smess] = mkdir(SdistPath);
   if ~isempty(Smess)
        disp(Smess)
   else
        disp('Destination folder created!')
   end
end

disp('Generating list of files ...')

cd(SinputPath)
system('tree --dirsfirst -i -f > listOfFiles.txt')

movefile('listOfFiles.txt',Spwd)
%% Moving to the destination folder
cd(SdistPath)

%import list of files
Nfid=fopen(fullfile(Spwd,'listOfFiles.txt'));

Cfiles{1} = fgetl(Nfid);
while ischar(Cfiles{end})
    Cfiles{end+1} = fgetl(Nfid); %#ok<AGROW>
end
fclose(Nfid);
%

for i = 1:length(Cfiles)-3 % first two records are . and .. directories
    
    [~,~,Sext] = fileparts(Cfiles{i});
    if strcmpi(Sext,'.m')
        disp(['pcoding file:' Cfiles{i}])
        pcode(fullfile(SinputPath,Cfiles{i}));
    else
        disp(['ignoring file:' SinputPath filesep Cfiles{i}])
    end
end
%% Copy the matlab database files

%% Return original folder
cd(Spwd)

