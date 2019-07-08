%**************************************************************************
%
%   Post-processor: eliminates unnecesary data in output.cos
%
%**************************************************************************

%function [] = POSTPROC()

%% 1.   Definition of some variables
Nel         = 3980;
FL1         = zeros(Nel,1);
FL2         = zeros(Nel,1);
step        = 10;
Sformat     = ['%*' num2str(31) 'c' '%f'];

%% 2.   Read Data from file
%2.1.   Open file
[Nfid Serror] = fopen('suspension_arm_FL.out','r'); % open ASCII file
%[Nfid Serror] = fopen('output.cos','r'); % open ASCII file
%2.2.   Read first character - load set 1
while 1,
    tline   = fgetl(Nfid);
    if ~ischar(tline),
        break; 
    end
    [String Nstart Nend]    = regexp(tline,'CUMULATIVE FATIGUE USAGE', 'match','start','end');
    if ~isempty(Nend),
        break;
    end
    if tline==-1
        Lerror  = true;
        OpenCossan.cossanDisp('EOF found');
        break
    end
end
FL1(1)  = sscanf(tline, Sformat);
%2.3.   Read rest of characters - load set 1
for i=2:Nel,
    for j=1:step,
        tline   = fgetl(Nfid);
        if tline==-1
            Lerror  = true;
            OpenCossan.cossanDisp('EOF found');
            break
        end
    end
    FL1(i)  = sscanf(tline, Sformat);
end
%2.4.   Read first character - load set 2
while 1,
    tline   = fgetl(Nfid);
    if ~ischar(tline),
        break; 
    end
    [String Nstart Nend]    = regexp(tline,'CUMULATIVE FATIGUE USAGE', 'match','start','end');
    if ~isempty(Nend),
        break;
    end
    if tline==-1
        Lerror  = true;
        OpenCossan.cossanDisp('EOF found');
        break
    end
end
FL2(1)  = sscanf(tline, Sformat);
%2.5.   Read rest of characters - load set 1
for i=2:Nel,
    for j=1:step,
        tline   = fgetl(Nfid);
        if tline==-1
            Lerror  = true;
            OpenCossan.cossanDisp('EOF found');
            break
        end
    end
    FL2(i)  = sscanf(tline, Sformat);
end
%2.6.   Close file
status=fclose(Nfid);

%% 3.   Write new file
[Nfid Serror] = fopen('suspension_arm_FL6.out','w');
%[Nfid Serror] = fopen('output.cos','w');
fprintf(Nfid,'FL= %f\n',FL1+FL2);
fclose(Nfid);

