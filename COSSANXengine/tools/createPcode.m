function createPcode(Sdist)
%% OpenCOSSAN build function 
% This function require the full path of the destination folder
% Created by MB
% Updated by Edoardo Patelli

assert(nargin==1,'openCOSSAN:createPcode', ...
    'The fullpath of the destination folder is required')
Spwd=pwd;

Ssrc=[OpenCossan.getCossanRoot filesep 'src'];

disp(['Cossan source folder: ' Ssrc])

Sdist=[Sdist filesep 'OPENCOSSANengine'];

disp(['Creating COSSANengine pcode in the foder: ' Sdist])
disp('Creating destination folder...')

%% create the target directory
[~, Smess] = mkdir(Sdist);

if ~isempty(Smess) % if the directory already exist
    disp('Directory already exist in target folder, skipping...')
    disp(Smess)
else
    disp('Destination folder created!')
end

disp('Generating list of files ...')

cd(Ssrc)
system('tree --dirsfirst -i -f > listOfFiles.txt')

movefile('listOfFiles.txt',Spwd)
%% Moving to the destination folder
cd(Sdist)

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
        pcode([Ssrc filesep Cfiles{i}]);
    else
        % disp(['ignoring file:' ssrc filesep cfiles{i}])
    end
end
%% Copy the matlab database files
cd(Spwd)
disp('Copying SFEM database files ... ')
[~, Smess] = mkdir(fullfile(Sdist,'database'));
copyfile(fullfile(OpenCossan.getCossanRoot,'database'),fullfile(Sdist,'database'))



%% Copy the mex files
disp('Copying mex files ... ')
[~, Smess] = mkdir(fullfile(Sdist,'mex'));
copyfile(fullfile(OpenCossan.getCossanRoot,'mex','bin'),fullfile(Sdist,'mex','bin'))


%% Copy docs
disp('Copying docs ... ')
copyfile(fullfile(OpenCossan.getCossanRoot,'docs'), [Sdist filesep 'docs'])
%% Copy Tutorials
disp('Copying Tutorials ... ')
copyfile(fullfile(OpenCossan.getCossanRoot,'examples','Tutorials'), ...
    fullfile(Sdist,'examples'))

%% Return original folder
cd(Spwd)

