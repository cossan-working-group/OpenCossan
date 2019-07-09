function Xidentifier=scanFile(Xobj,Nfid)
%SCANFILE This is a private function of the Injector object. It is used to
%scan ASCII files for cossan identifiers (i.e. XLM tag <cossan />)
%
% Input arguments:
% * 'Nfid' identifiers of the file to be scanned;
%
%  'Xidentifier' Identifier object
%
% initialize variables
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Injector
%
% Author: Matteo Broggi and Edoardo Patelli
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

import opencossan.workers.ascii.Identifier

Npreallocateblock = 1000;
line_id = 0; var_id = 0;

%% Preallocate memory
CMmaster=cell(Npreallocateblock,1);

while 1
    Stline = fgetl(Nfid);    % read one line at time
    line_id = line_id + 1;
    NlengthLine=length(Stline);
    
    % EOF identified
    if ~ischar(Stline)  % this is not an error
        break % Exit from the while loop
    end
    
    % find a matching identifier
    [Cm, s, e] = regexp(Stline,Xobj.Sexpr, 'match', 'start', 'end');
    
    if ~isempty(s)
        for it=1:length(s)
            var_id=var_id+1;
            
            if var_id>length(CMmaster)
                % expand the allocated memory of CMmaster
                CMmaster{length(CMmaster)+Npreallocateblock} = [];
            end            
            % introduced to make the overwrite procedure faster!
            fseek(Nfid,0,'cof');
            Nposition = ftell(Nfid);
            
            [tmp_name] = regexp(Cm(it), Xobj.Sexpr_name, 'tokens');
            [tmp_index] = regexp(Cm(it), Xobj.Sexpr_index, 'tokens');
            [tmp_format] = regexp(Cm(it), Xobj.Sexpr_format, 'tokens');
            [tmp_original] = regexp(Cm(it), Xobj.Sexpr_originalvalue, 'tokens');
            [tmp_includefile] = regexp(Cm(it), Xobj.Sexpr_includefile, 'tokens');
            
            if ~isempty(tmp_format{1})
                switch lower(tmp_format{1}{1}{1})
                    
                    case {'nastran8','nastran16_table'}
                        Nstringlength=8;
                    case {'nastran16'}
                        Nstringlength=16;
                    case {'abaqus_table'}
                        Nstringlength=length(tmp_name);
                    otherwise
                        % check if more than 1field is present into the format
                        % field
                        [Vpos]=regexp(tmp_format{1}{1}{1},'%');
                        
                        if length(Vpos)>1
                            warning('COSSAN:injector:scan_file','Multiple fields in the injector are not allowed');
                            tmp_format{1}{1}{1}=tmp_format{1}{1}{1}(Vpos(1):Vpos(2)-1);
                        end
                        
                        try
                            [Cstringlength] = regexp(Cm(it), Xobj.Sexpr_formatlength, 'tokens');
                            Nstringlength=str2double(Cstringlength{1}{1}{1}); %use only the first value of format
                        catch ME
                            error('openCOSSAN:Injector:scanFile',...
                                strcat('Unknown format found in file "%s".',...
                                '\nFormat          : %s',...
                                '\nIdentifier name : %s', ...
                                '\nLine            : %i'),...
                                Xobj.Sscanfilename,tmp_format{1}{1}{1},tmp_name{1}{1}{1},line_id);
                        end
                end
            end
            % store data in a cell array
            CMmaster{var_id}.Sname    = tmp_name{1}{1}{1};            
            if isempty(tmp_index{1})
                CMmaster{var_id}.Nindex = 1;
            else
                CMmaster{var_id}.Nindex = str2double(tmp_index{1}{1}{1});
            end
            
            if isempty(tmp_format{1})
                warning('COSSAN:injector:scan_file',...
                    strcat('Format field value not defined in file "%s".',...
                    '\nUsing default format %10.4e.',...
                    '\nIdentifier name : %s', ...
                    '\nLine            : %i'),...
                    Xobj.Sscanfilename,tmp_format{1}{1}{1},tmp_name{1}{1}{1},line_id);
                CMmaster{var_id}.Sformat  = '%10.4e';
                Nstringlength = 10;
            else
                CMmaster{var_id}.Sformat  = tmp_format{1}{1}{1};
            end
            
            CMmaster{var_id}.Ntotfield= e(it)-s(it)+1;
            
            if isempty(tmp_original{1})
                CMmaster{var_id}.Soriginal  = '0';
                warning('COSSAN:injector:scan_file:noOriginalField',...
                    strcat('Original field value not available in the scanned file "%s".',...
                    '\nDeterministic analysis will not perform.',...
                    '\nIdentifier name : %s', ...
                    '\nLine            : %i'),...
                    Xobj.Sscanfilename,tmp_name{1}{1}{1},line_id);
            else
                CMmaster{var_id}.Soriginal=tmp_original{1}{1}{1};
                
                % Check original format length is equal to the format
                if length(tmp_original{1}{1}{1})>Nstringlength
                    warning('COSSAN:injector:scan_file:WrongOriginalFieldLenght',...
                        strcat('Original field length (%i) does not match with the format lenght defined (%i).',...
                        '\nIdentifier name : %s', ...
                        '\nLine            : %i'),...
                        length(tmp_original{1}{1}{1}),Nstringlength,tmp_name{1}{1}{1},line_id);
                end
                
            end
            
            if isempty(tmp_includefile{1})
                if ~isempty(strfind(CMmaster{var_id}.Sformat,'table'))
                    error('COSSAN:injector:scanfile',...
                        ['Definition of includefile missing in the identifier of the Stochastic Process ',...
                        CMmaster{var_id}.Sname]);
                else
                    CMmaster{var_id}.includefile  = [];
                end
            else
                CMmaster{var_id}.includefile=tmp_includefile{1}{1}{1};
            end
            
            Ntotfield=0;
            Ntotfield=Ntotfield+Nstringlength;
            
            CMmaster{var_id}.Nstringlength=Ntotfield;
            
            % store the absolute position inside the file          
            if var_id==1
                Ndelta=0;
                Ndelta0=Ndelta+length(Cm{it});
            else
                Ndelta=Ndelta0;
                Ndelta0=Ndelta0+length(Cm{it});
            end            
            % the final position must be determined once the
            % value has been written
            CMmaster{var_id}.Nposition=Nposition-NlengthLine+s(it)-Ndelta-2;
        end
    end
end

%% Create Identifier Object
% Preallocation of memory
if var_id == 0
    % if var_id is 0, no identifiers are present in the file and
    % an empty Identifier is returned
    Xidentifier = [];
else
    % Create identifiers
    Xidentifier(var_id) = Identifier('Sname',CMmaster{var_id}.Sname,...
        'Nindex',CMmaster{var_id}.Nindex,...
        'Sfieldformat',CMmaster{var_id}.Sformat,...
        'Nposition',CMmaster{var_id}.Nposition,...
        'Soriginal',CMmaster{var_id}.Soriginal);
    for ivar=1:var_id
        Xidentifier(ivar) = Identifier('Sname',CMmaster{ivar}.Sname,...
            'Nindex',CMmaster{ivar}.Nindex,...
            'Sfieldformat',CMmaster{ivar}.Sformat,...
            'Nposition',CMmaster{ivar}.Nposition,...
            'Soriginal',CMmaster{ivar}.Soriginal,...
            'Sincludefile',[Xobj.Srelativepath CMmaster{ivar}.includefile]);
    end
end
