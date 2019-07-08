function TfileInfo = findRelativePosition(Xresponse,Nfid,TfileInfo)

% TresponsePosition contains the position of the relative response or the
% anchor (Clookoutfor) as well the position of all the lines already
% scanned.


% Initialise variables
Lreset=false;



%% Scan for a text
if ~isempty(Xresponse.Clookoutfor)
    
    if Xresponse.NrepeatAnchor>1 && ~isempty(TfileInfo.Vpos)
        status=fseek(Nfid,max(TfileInfo.Vpos), 'bof');
        TfileInfo.Vpos(end+1)=ftell(Nfid);
    end
    
    % Search the Clookoutfor strings
    for ilook=1:length(Xresponse.Clookoutfor)
        Nfound=[];
        while isempty(Nfound)
            tline = fgetl(Nfid);
            % Store the position
            TfileInfo.Vpos(end+1)=ftell(Nfid);
            
            
            if Xresponse.NrepeatAnchor==Inf && ~ischar(tline)
                % If the end of file is reached when NrepeatAnchor is set
                % to Inf do not return an error but simply exit the loop
                TfileInfo.status='completed';
                return
            elseif ~ischar(tline) && Lreset
                warning('OpenCossan:Response:findRelativePosition',...
                    ['End of file reached (again) while looking for the '...
                    Xresponse.Sname ' response.\n'])
                TfileInfo.out.(Xresponse.Sname)=NaN;
                TfileInfo.status='error';
                return
            elseif ~ischar(tline) && ~Lreset
                warning('OpenCossan:Response:findRelativePosition',...
                    ['File position reset while looking for the '...
                    Xresponse.Sname ' response.\n'...
                    'Be sure to define reponses in the order they appear ' ...
                    'in the output file to improve performance'])
                fseek(Nfid, 0, 'bof'); % reset file position
                TfileInfo.Vpos(end+1)=ftell(Nfid);
                TfileInfo.status='reset';
            else
                Nfound = regexp(tline, Xresponse.Clookoutfor{ilook}, 'end');
            end
        end
    end
    TfileInfo.out.(Xresponse.Sname)=ftell(Nfid);
    
    %% Use position of other variable
elseif ~isempty(Xresponse.Svarname)
    % Vcolnum and Vrownum are relative respect to the variable present in Svarname
    try
        positioncurrent = TfileInfo.out.(Xresponse.Svarname);
    catch ME
        warning('OpenCossan:Response:findRelativePosition',...
            ['Position of the response ' Xresponse.Svarname ' not found \n ' ME.message])
        OpenCossan.cossanDisp('Continue with the next response',1)
        TfileInfo.out.(Xresponse.Sname)=NaN;
        return
    end
    Serror= fseek(Nfid, positioncurrent, 'bof');
    if Serror~=0
        warning('OpenCossan:Response:findRelativePosition',...
            ['Seeking position of ' Xresponse.Svarname ' not found \n '])
        TfileInfo.out.(Xresponse.Sname)=NaN;
        return
    end
else
    % Extract using absolute position
    fseek(Nfid, 0, 'bof'); % reset file position
    % Store the position
    TfileInfo.Vpos(end+1)=ftell(Nfid);
end

%% Now skip Nrownum  from the current position
if Xresponse.Nrownum<=0
    % More to previous lines
    status=fseek(Nfid,TfileInfo.Vpos(end+Xresponse.Nrownum-1), 'bof');
    TfileInfo.Vpos(end+1)=ftell(Nfid);
    if status==-1
        warning('OpenCossan:Response:problemRelativePosition',...
            'Problems moving to the relative position for the output %s', Xresponse.Sname);
        TfileInfo.out.(Xresponse.Sname)=NaN;
        return
    end
else
    for i=1:Xresponse.Nrownum-1
        tline=fgetl(Nfid);
        % Store file pointer
        TfileInfo.Vpos(end+1)=ftell(Nfid);
        if tline==-1
            warning('OpenCossan:Response:readResponse',...
                'Problems extracting value(s) for %s', Xresponse.Sname);
            TfileInfo.out.(Xresponse.Sname)=NaN;
            % exit from the loop if the end of file is found
            return
        end
    end
end
