function save(XsimOut,varargin)
%SAVE This method save each component of the SimulationData object in a
%separate variable in order to overcome the Matlab bug of the memory
%allocation of the function cell2mat
%
%   MANDATORY ARGUMENTS
%   * Name of the output file name
%
%   OUTPUT
%   - Optional output
%
%   USAGE
%   Status = XsimOut.save('SfileName','myFileName')
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/save@SimulationData
%
% Copyright 1983-2015 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

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


%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

Tsize=[];
%% Check Inputs
for k=1:2:nargin-1,
    switch lower(varargin{k})
        case {'sfilename'}
            %check input
            SfileName = varargin{k+1};
        otherwise
            error('openCOSSAN:output:SimulationData:save', ...
                'PropertyName is not valid %s ', varargin{k})
    end
end

% Pre-extract all the values inside the SimulationData object in a
% structure
Tvalues = XsimOut.Tvalues;
Cnames = fieldnames(Tvalues);
Nsamples = length(Tvalues);


if isempty(Cnames)
    OpenCossan.cossanDisp('SimulationData does not contain any results. Nothing to save',2)
end

Texp=struct; % Create an empty structure

%% Retrieve the individual components
Cfullout=struct2cell(Tvalues);
for iname=1:length(Cnames)
    %Pfield=Tvalues.(Cnames{iname});
    switch class(Cfullout{iname})
        case 'double'
            Cout = Cfullout(iname,:);
            %% Check if the values are also store in a Matrix format
            if isempty(XsimOut.Mvalues)
                if isempty(Cout)
                    warning('openCOSSAN:outputs:SimulationData:getValues', ...
                        'Variable %s is not available',Sname)
                    Mvalues=[];
                else
                    if ~isvector(Cout{1})
                        for n=1:length(Cout)
                            Cout{n}=Cout{n}(:);
                            %Cout{n}=reshape(Cout{n},Nelement,1);
                        end
                    end
                    if isempty(Cout{end})
                        % Cout is a Parameters (i.e. only the first element
                        % is not empty)
                        Mvalues=Cout{1};
                    else
                        %Mvalues=myCell2Mat(Cout);
                        if length(Cout{1})==1
                            Mvalues=zeros(size(Cout));
                            for n=1:numel(Cout);
                                Mvalues(n)=Cout{n};
                            end
                        else
                            % This case should store the stochastic process
                            Mvalues=zeros(length(Cout{1}),length(Cout));
                            for n=1:numel(Cout);
                                Mvalues(:,n)=Cout{n};
                            end
                        end
                    end
                end
                
            else
                % The method cell2mat transpose the matrix
                Mvalues=transpose(XsimOut.Mvalues(:,iname));
            end
            
            Texp.(Cnames{iname})=Mvalues;
            Tsize.(Cnames{iname})=size(Cout{1});
        case 'Dataseries'
            Texp.(Cnames{iname}) = XsimOut.getDataseries('Sname',Cnames{iname});
            % The following line stores the dimension of the Dataseries
            % (i.e. size(Cfullout{iname,1}.Mcoord ) 
            Tsize.(Cnames{iname}) = [Cfullout{iname,1}.Ndimensions Cfullout{iname,1}.VdataLength];
        otherwise
            % If an object is stored in the SimulationData
            for n=1:size(Cfullout,2)
                Texp.(Cnames{iname})(n)=Cfullout{iname,n};
            end
            Tsize.(Cnames{iname})=size(Cfullout{iname,1});
    end
end



%% Save number of samples in a field
if ~isfield(Texp,'SimOutReserved_Tsize')
    Texp.SimOutReserved_Tsize=Tsize;
else
    warning('openCOSSAN:output:SimulationData:save', ...
        ['The size of matrices of the object can not be saved \n ' ...
        ' due to the presence of a variable named SimOutReserved_Tsize'])
end


if ~isfield(Texp,'SimOutReserved_Nsamples')
    Texp.SimOutReserved_Nsamples=Nsamples;
else
    warning('openCOSSAN:output:SimulationData:save', ...
        ['The number of samples of the object can not be saved \n ' ...
        ' due to the presence of a variable named SimOutReserved_Nsamples'])
end

if ~isfield(Texp,'SimOutReserved_Sdescription')
    Texp.SimOutReserved_Sdescription=XsimOut.Sdescription;
else
    warning('openCOSSAN:output:SimulationData:save', ...
        ['The description of the object can not be saved \n ' ...
        ' due to the presence of a variable named SimOutReserved_Sdescription'])
end

if ~isfield(Texp,'SimOutReserved_Cnames')
    Texp.SimOutReserved_Cnames=Cnames; %#ok<STRNU>
else
    warning('openCOSSAN:output:SimulationData:save', ...
        ['The names of the variables of the object can not be saved \n ' ...
        ' due to the presence of a variable named SimOutReserved_Cnames'])
end

%% Save components
save(SfileName,'-struct','Texp')

