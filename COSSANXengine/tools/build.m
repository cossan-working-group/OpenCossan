function build(Ssrc,Sdist,varargin)
%% OpenCossan build function

mess = [];
if ~isempty(varargin)
    % if it is not the first time the build function is invoked, create the
    % target directory
    [~, mess] = mkdir(Sdist);
end

if ~isempty(mess) % if the directory already exist
    OpenCossan.cossanDisp('Directory already exist in target folder, skipping...')
else
    % get the contents of the src directory
    Tdir = dir(Ssrc);
    for i = 3:length(Tdir) % first two records are . and .. directories
        if ~strcmpi(Tdir(i).name(1),'.') && ~strcmpi(Tdir(i).name(end),'~')
            % ignore hidden files and backup files
            if ~Tdir(i).isdir
                % if it is not a directory, check whether is a .m file
                [~, file, ext] = fileparts(Tdir(i).name);
                if strcmpi(ext,'.m')
                    % encrypt the .m file and move it to the distribution directory
                    OpenCossan.cossanDisp(['Pcoding file:' Ssrc '/' Tdir(i).name])
                    pcode([Ssrc filesep Tdir(i).name],'-inplace');
                    movefile([Ssrc filesep file '.p'], Sdist);
                else
                    % copy the file to the dist directory
                    OpenCossan.cossanDisp(['Copying file:' Ssrc '/' Tdir(i).name])
                    copyfile([Ssrc filesep Tdir(i).name], Sdist);
                end
            else
                % recursively build the content of the directory
                OpenCossan.cossanDisp(['Entering directory:' [Ssrc filesep Tdir(i).name]])
                build([Ssrc filesep Tdir(i).name],[Sdist filesep Tdir(i).name],0);
            end
        end
    end
end
end