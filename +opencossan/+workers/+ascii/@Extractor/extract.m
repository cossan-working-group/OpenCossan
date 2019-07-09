function [Tout,LsuccessfullExtract] = extract(Xobj,varargin)
%EXTRACTOR  extract values form a ASCII file and create a structure Tout
%
% See Also: http://cossan.co.uk/wiki/index.php/extract@Connector
%
% $Copyright~2006-2017,~COSSAN~Working~Group$
% $Author: Matteo Broggi and Edoardo Patelli$

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

%% 1. Processing Inputs

opencossan.OpenCossan.validateCossanInputs(varargin{:});
for iopt=1:2:length(varargin)
    switch lower(varargin{iopt})
        case {'nsimulation'}
            Nsimulation = varargin{iopt+1};
        otherwise
            warning('openCOSSAN:Extractor:extract',...
                ['Optional parameter ' varargin{iopt} ' not allowed']);
    end
end

if ~exist('Nsimulation','var')
    Nsimulation = 1;
end

LsuccessfullExtract = true;
% extract the property Xresponse from the extractor (performance is greatly
% improved by using this vector of responses instead of accessing the
% property of the extractor)
Xresponse = Xobj.Xresponse;
% if no responses are defined in the extractor, throws a warning and
% returns an empty output structure
if isempty(Xresponse)
    warning('openCOSSAN:Extractor:extract',...
        'The Extractor has no responses. Define some responses or remove the Extractor')
    Tout = struct;
    return
end

%% 3. Access to the output file

[Nfid,Serror] = fopen(fullfile(Xobj.Sworkingdirectory,Xobj.Srelativepath,Xobj.Sfile),'r'); % open ASCII file
opencossan.OpenCossan.cossanDisp(['[COSSAN-X.Extractor.extract] Open file : ' fullfile(Xobj.Sworkingdirectory,Xobj.Srelativepath,Xobj.Sfile)],4 )

% Return NaN value if an error occurs in the extractor
if ~isempty(Serror)
    warning('openCOSSAN:Extractor:extract',...
        strrep(['The results file ' fullfile(Xobj.Sworkingdirectory,Xobj.Srelativepath,Xobj.Sfile) ' of simulation #' num2str(Nsimulation) ' does not exist'],'\','\\'))
    for iresponse=1:Xobj.Nresponse
        if Xresponse(iresponse).Nrows ==1 || Xresponse(iresponse).Ndata ==1
            Tout.(Xresponse(iresponse).Sname)=NaN;
        else
            % be consistent if you need a dataseries output...
            Tout.(Xresponse(iresponse).Sname)=Dataseries;
        end
        LsuccessfullExtract = false;
    end
    return;
else
    OpenCossan.cossanDisp('[COSSAN-X.Extractor.extract] File Open correctly',4 )
end

%% Extract the values from file

for iresponse=1:Xobj.Nresponse
    
    % already_reset is a flag that check whether the end of file have been
    % already reached while looking for the iresponse-th response
    already_reset = false;
    
    if ~isempty(Xresponse(iresponse).Sregexpression)
        while 1
            tline = fgetl(Nfid);
            %positioncurrent = ftell(Nfid);
            if ~ischar(tline)
                if already_reset
                    warning('openCOSSAN:Extractor:extract','End of file reached');
                    break
                else
                    already_reset = true; % set the flag to true
                    warning('openCOSSAN:Extractor:extract',...
                        ['File position reset while looking for the '...
                        num2str(iresponse) '-th response.\n'...
                        'Be sure to define reponses in the order they appear in the output file to improve performance'])
                    fseek(Nfid, 0, 'bof'); % reset file position
                    tline = fgetl(Nfid);
                end
            end
            Nfound=regexp(tline, Xresponse(iresponse).Sregexpression,'end');
            if ~isempty(Nfound)
                break,
            end
        end
        
    elseif ~isempty(Xresponse(iresponse).Clookoutfor)
        % Search the Clookoutfor strings
        for ilook=1:length(Xresponse(iresponse).Clookoutfor)
            Nfound=[];
            while isempty(Nfound)
                tline = fgetl(Nfid);
                if ~ischar(tline)
                    if already_reset
                        warning('openCOSSAN:Extractor:extract','End of file reached');
                        break
                    else
                        already_reset = true; % set the flag to true
                        warning('openCOSSAN:Extractor:extract',...
                            ['File position reset while looking for the '...
                            num2str(iresponse) '-th response.\n'...
                            'Be sure to define reponses in the order they appear in the output file to improve performance'])
                        fseek(Nfid, 0, 'bof'); % reset file position
                        tline = fgetl(Nfid);
                    end
                end
                Nfound = regexp(tline, Xresponse(iresponse).Clookoutfor{ilook}, 'end');
            end
        end
    elseif ~isempty(Xresponse(iresponse).Svarname)
        try
            positioncurrent = Tpos.(Xresponse(iresponse).Svarname);
        catch ME
            warning('openCOSSAN:Extractor:extract',...
                ['Position of the response ' Xresponse(iresponse).Svarname ' not found \n ' ME.message])
            OpenCossan.cossanDisp('Continue with the next response',1)
            Tout.(Xresponse(iresponse).Sname)=NaN;
            LsuccessfullExtract = false;
            continue
        end
        Serror= fseek(Nfid, positioncurrent, 'bof');
        if Serror~=0
            Tout.(Xresponse(iresponse).Sname)=NaN;
            LsuccessfullExtract = false;
            continue
        end
    end
    
    % Now skip Nrow from the current position
    if isa(Xresponse(iresponse).Nrownum,'char')
        Xresponse(iresponse).Nrownum=str2num(Xresponse(iresponse).Nrownum); %#ok<ST2NM>
    end
    
    for i=1:Xresponse(iresponse).Nrownum
        tline=fgetl(Nfid);
        if tline==-1, break, end % exit from the loop if the end of file is found
    end
    
    if tline==-1
        warning('openCOSSAN:Extractor:extract',...
            ['Problems extracting value(s) for ' Xresponse(iresponse).Sname ' of simulation #' num2str(Nsimulation)]);
        Tout.(Xresponse(iresponse).Sname)=NaN;
        Tpos.(Xresponse(iresponse).Sname)=NaN;
        LsuccessfullExtract = false;
        continue
    end
    
    % Now skip Ncol from the current position and
    % finally read the variable
    
    if Xresponse(iresponse).Ncolnum<=1
        Sformat=[Xresponse(iresponse).Sfieldformat '%*'];
    else
        Sformat=['%*' num2str(Xresponse(iresponse).Ncolnum-1) 'c' Xresponse(iresponse).Sfieldformat '%*'];
    end
    
    % The scanf function skip the Xresponse(iresponse).Ccolnum{1}
    % characters and than read the real value
    
    clear Moutput;
    
    % introduce countdown counter for support for both finite and infinite
    % Nrepeat (infinite means repeat until the end of the file)
    countdown=Xresponse(iresponse).Nrepeat;
    iresp = 1;
    while countdown > 0
        Mextracted=sscanf(tline, Sformat);
        if isinf(countdown) && logical(isempty(Mextracted))
            break
        else
        assert(logical(~isempty(Mextracted)),...
            'openCOSSAN:Extractor:extract',...
            'Extracted empty string\nLine: "%s"\nFormat: "%s"',...
            tline,Sformat)
        end
        
        Moutput(iresp,:) = Mextracted; %#ok<AGROW>
        iresp = iresp + 1;
        
        % get the next line
        countdown=countdown-1;
        tline=fgetl(Nfid);
        if ~ischar(tline)
            if xor(~isinf(countdown),countdown==0)
                warning('openCOSSAN:Extractor:extract',...
                    ['It was not possible to extract ' Xresponse(iresponse).Sname ...
                    ' ' num2str(Xresponse(iresponse).Nrepeat) ' times, '...
                    'but only ' num2str(size(Moutput,1)) ' times.'])
            end
            countdown = 0;
        end
    end
    
    % Associate read value with the output parameter
    try
        OpenCossan.cossanDisp(['[COSSAN-X.Extractor.extract] Response #' num2str(iresponse) ': ' ],4 )
        OpenCossan.cossanDisp('[COSSAN-X.Extractor.extract] Value(s) extracted: ' ,4 )
        if OpenCossan.getVerbosityLevel>3
            Moutput %#ok<NOPRT>
        end
        % check the size of Moutput to assign to the right object
        if numel(Moutput)==1
            % Moutput is a scalar, thus it is saved directly in the output
            % structure
            Tout.(Xresponse(iresponse).Sname)=Moutput;
        else
            % Moutput is a vector/matrix, thus it is saved in a Dataseries
            % according to the properties of the response object
            Tout.(Xresponse(iresponse).Sname)= Xresponse(iresponse).createDataseries(Moutput);
        end
    catch ME
        OpenCossan.cossanDisp(['[COSSAN-X.Extractor.extract] Failed to associate extracted value to the output ( ' ME.message ')' ],4 )
        fclose(Nfid);
        return
    end
    % save the position of the last extracted value
    Tpos.(Xresponse(iresponse).Sname)=ftell(Nfid);
end

% close the file
status=fclose(Nfid);
if ~isempty(status)
    OpenCossan.cossanDisp(['[COSSAN-X.Extractor.extract] Closing output files (status: ' status ')' ],4 )
end