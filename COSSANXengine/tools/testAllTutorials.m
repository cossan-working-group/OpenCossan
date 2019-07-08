%% Test All the Tutorials
function testAllTutorials

clear globals Cfiles Tresults
global Cfiles Tresults

SworkingPath='/tmp/Tutorials/';
mkdir (SworkingPath)
Spwd=pwd; % Store corrent directory

initializeCossan('NverboseLevel',0,'Scossanworkingpath',SworkingPath, ...
    'ScossanExternalPath','/home/ep/workspace/COSSAN-X_SVN/OpenSourceSoftware');

cd(Spwd);

%system('tree --dirsfirst -i -f > listOfFiles.txt')

% import list of files
Nfid=fopen('listOfFiles.txt');

Cfiles{1} = fgetl(Nfid);
while ischar(Cfiles{end})
    Cfiles{end+1} = fgetl(Nfid); %#ok<AGROW>
end

fclose(Nfid);
Spwd=pwd; % Store corrent directory


Nsuccess=0;
for n=1:length(Cfiles)
    disp(['Test number ' num2str(n) '/' num2str(length(Cfiles)) ])
    % Check if the entriy is a directory
    if isdir(fullfile(Spwd,Cfiles{n}))
        % Enter in the folder
        cd(fullfile(Spwd,Cfiles{n}))
    else
        [Spath, Sname, Sext] = fileparts(Cfiles{n});
        cd([Spwd Spath(2:end)])
        if strcmp(Sext,'.m')
            % Check if the matlab file is a function or a script
            Nfid2=fopen([Sname,'.m']);
            Sfirstline = fgetl(Nfid2);
            fclose(Nfid2);
            if isempty(strfind(Sfirstline,'function '))
                
                Tresults(end+1).Sname=fullfile(pwd,Sname); %#ok<AGROW>
                Tresults(end).Sdate=datestr(now);
                tic
                % Run tutorial
                try
                    evalin('base',['run ' Sname ]);
                    Tresults(end).Lstatus=true;
                    Nsuccess=Nsuccess+1;
                catch ME
                    if ~exist('Tresults','var')
                        disp('Variables cleared' )
                        ME.message
                    end
                    Tresults(end).Lstatus=false;
                    Tresults(end).Cmess={ME.message};
                end
                Tresults(end).wallclocktime=toc;
            end
        end
    end
end

Ntest=length(Tresults);

%% Print Report
Tinfo=getSystemInfo;

Nfid=fopen('ReportTutorials.txt','w+');
fprintf(Nfid,'%s\n','*********************************************************************');
fprintf(Nfid,'%s\n',[' REPORT OF TUTORIALS TEST (' datestr(now) ')']);
fprintf(Nfid,'%s\n',' ');
fprintf(Nfid,'%s\n',[' Matlab version : ' Tinfo.Smatlabversion ' Architecture: ' Tinfo.Sarch]);
fprintf(Nfid,'%s\n',[' Host Machine OS: ' Tinfo.Sdistribution ' (' Tinfo.Srelease ')']);
fprintf(Nfid,'%s\n',' ');
fprintf(Nfid,'%s\n',[' Successful: ' num2str(100*(Nsuccess/Ntest)) '%']);
fprintf(Nfid,'%s\n','*********************************************************************');

%% Show summary
fprintf(Nfid,'\n\n%s\n','Details of the test');
for itest=1:length(Tresults)
    fprintf(Nfid,'%s\n',['Function name: ' Tresults(itest).Sname]);
    if Tresults(itest).Lstatus
        fprintf(Nfid,'%s\n',[' Status:     OK;  CPU Time ' num2str( Tresults(itest).wallclocktime)]);
    else
        fprintf(Nfid,'%s\n',[' Status: FAILED;  CPU Time ' num2str( Tresults(itest).wallclocktime)]);
        fprintf(Nfid,'%s\n',strcat(Tresults(itest).Cmess{:}));
    end
end
fprintf(Nfid,'%s\n','*********************************************************************');
fclose(Nfid);
