function [Tout,LsuccessfullExtract] = extract(Xobj,varargin)
%EXTRACTOR  extract values form a ASCII file and create a structure Tout
%
% See Also: https://cossan.co.uk/wiki/index.php/extract@Connector
%
% $Copyright~2006-2018,~COSSAN~Working~Group$
% $Author: Matteo Broggi and Edoardo Patelli$

%
% =====================================================================
% This file is part of OpenCossan.  The open general purpose matlab
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

%% Initialisation
% Nsimulation is only use to display messages.
Nsimulation = 1;
LresponseSuccessfullExtract = false(Xobj.Nresponse,1);

% extract the property Xresponse from the extractor (performance is greatly
% improved by using this vector of responses instead of accessing the
% property of the extractor)
Xresponse = Xobj.Xresponse;

%% Processing Inputs
OpenCossan.validateCossanInputs(varargin{:});
for iopt=1:2:length(varargin)
    switch lower(varargin{iopt})
        case {'nsimulation'}
            Nsimulation = varargin{iopt+1};
        otherwise
            warning('OpenCossan:Extractor:extract:wrongOption',...
                ['Optional parameter ' varargin{iopt} ' not allowed']);
    end
end

% if no responses are defined in the extractor, throws a warning and
% returns an empty output structure
Tout = struct;
if isempty(Xresponse)
    warning('OpenCossan:Extractor:extract:NoResponses',...
        'The Extractor has no responses.\n Define at least one Response object or remove the Extractor object from the Connector')
    LsuccessfullExtract=false;
    return
end

%% Access to the output file
SfullFileName=fullfile(Xobj.Sworkingdirectory,Xobj.Srelativepath,Xobj.Sfile);
% open ASCII file
[Nfid,Serror] = fopen(SfullFileName,'r');
OpenCossan.cossanDisp(['[OpenCossan.Extractor.extract] Open file : ' ...
    SfullFileName],4 )

% Return NaN value if an error occurs in the extractor
if ~isempty(Serror)
    warning('OpenCossan:Extractor:extract:noFile',...
        strrep(['The results file ' SfullFileName ...
        ' of simulation #' num2str(Nsimulation) ' does not exist'],'\','\\'))
    for iresponse=1:Xobj.Nresponse
        if Xresponse(iresponse).Nrows ==1 || Xresponse(iresponse).Ndata ==1
            Tout.(Xresponse(iresponse).Sname)=NaN;
        else
            % be consistent if you need a dataseries output...
            Tout.(Xresponse(iresponse).Sname)=Dataseries;
        end
    end
    return;
else
    OpenCossan.cossanDisp(['[OpenCossan.Extractor.extract] File ' SfullFileName ...
        ' open correctly'],4 )
end

%% Extract the values from file
% Initialise structure storing values of variables 
TfileInfo=struct('Vpos',[],'out',[],'status',[]);
LresponseSuccess=true(1,Xobj.Nresponse);
for iresponse=1:Xobj.Nresponse
    % Process     
    [Tresponse,TfileInfo,LresponseSuccess(iresponse)]= ...
        Xresponse(iresponse).extract('Nfid',Nfid,...
        'Nsimulation',Nsimulation,'TresponsePosition',TfileInfo);
    Tout.(Xresponse(iresponse).Sname)=Tresponse.(Xresponse(iresponse).Sname);
    
end

% close the file
status=fclose(Nfid);
if ~isempty(status)
    OpenCossan.cossanDisp(['[COSSAN-X.Extractor.extract] Closing output files (status: ' status ')' ],4 )
end

LsuccessfullExtract=all(LresponseSuccessfullExtract);