classdef SimulationData
    %SIMULATIONDATA Class definition of the SimulationData object
    %
    % See Also: Also: https://cossan.co.uk/wiki/index.php/@SimulationData
    
    properties
        Tvalues=struct; % Structure containing the values of the variables
        Sdescription    % Description of the object
        SexitFlag       % Description of the termination criteria
        SbatchFolder    % Store the batch name of the batch folder
    end
    
    properties (Dependent = true, SetAccess = private)
        Cnames           % Names of the variables present in the object
        CnamesDataseries % Extract the names of dataseries
        Nsamples         % Number of samples
    end
    
    properties (SetAccess=private)
        Mvalues         % Matrix containing the values of the variables
        LisDataseries   % flag for dataseries
    end
    
    methods
        % SIMULATIONDATA This method constructs a SimulationData object. The
        % object is used to store the results of the simulation.
        %
        % See Also: https://cossan.co.uk/wiki/index.php/@SimulationData
        %
        % Author: Edoardo Patelli
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
        
        function Xobj=SimulationData(varargin)
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'tvalues'}
                        % Tvalues must be a column vector
                        if size(varargin{k+1},2)>1
                            Xobj.Tvalues=varargin{k+1}';
                        else
                            Xobj.Tvalues=varargin{k+1};
                        end
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'sexitflag'}
                        Xobj.SexitFlag=varargin{k+1};
                    case {'cvariablenames','cnames'}
                        Cnames=varargin{k+1};
                        if size(Cnames,1)>1
                            Cnames=Cnames';
                        end
                    case {'mvalues'}
                        Xobj.Mvalues=varargin{k+1};
                    case {'sbatchfolder'}
                        Xobj.SbatchFolder=varargin{k+1};
                    otherwise
                        error('openCOSSAN:SimulationData', ...
                            ['PropertyName (' varargin{k} ' ) is not allowed']);
                end
            end
            
            % Construct SimulationData from a matrix
            if exist('Cnames','var')
                if isempty(Xobj.Mvalues)
                    error('openCOSSAN:SimulationData', ...
                        'It is mandatory to pass Mvalue field if the Cnames are defined');
                end
                
                if length(Cnames)~=size(Xobj.Mvalues,2)
                    error('openCOSSAN:SimulationData', ...
                        ['The number of variable defined in Cvariablenames (' ...
                        num2str(length(Cnames)) ') does not match with the ' ...
                        'number of columns of Mvalues (' num2str(size(Xobj.Mvalues,2)) ')']);
                end
                
                % Construct Tvalues (this is probably the fasted way to
                % construct the structure, see speedtest in the
                % Unit_test/SimulationData)
                
                Xobj.Tvalues=cell2struct(num2cell(Xobj.Mvalues),Cnames,2);
                
            else
                Cnames=Xobj.Cnames; %Retrieve names of variable
            end
            
            % Try to populate the field Mvalues for a fast access to the
            % values
            if isempty(Xobj.Mvalues) && ~isempty(Xobj.Tvalues)
                Cvalues=struct2cell(Xobj.Tvalues)';
                
                if ~isempty(Cvalues)
                    Vlen = cellfun('prodofsize', Cvalues);
                    %Cnames=XSimOut.Cnames;
                    
                    if all(Vlen==Vlen(1))
                        if (Xobj.Nsamples==Vlen(1))
                            Vchecknumeric = zeros(1,size(Cvalues,2));
                            for nfield = 1:size(Cvalues,2)
                                Vchecknumeric(nfield)=isnumeric(Cvalues{1,nfield});
                            end
                            if all(Vchecknumeric)==1
                                Xobj.Mvalues=zeros(size(Cvalues));
                                Xobj.Mvalues = cell2mat(Cvalues);
                            end
                            %Xobj.Mvalues=myCell2mat(Cvalues);
                            %Xobj.Mvalues=reshape(struct2array(XSimOut.Tvalues), ...
                            %                      XSimOut.Nsamples,length(Cnames));
                        end
                    end
                end
            end
            
            % Store output type
            
            Xobj.LisDataseries=false(length(Cnames),1);
            for n=1:length(Cnames)
                try
                    Xobj.LisDataseries(n)=isa(vertcat(Xobj.Tvalues.(Cnames{n})),'Dataseries');
                catch ErrorMessage
                    % The vertcat is going to fail if the output comes from
                    % a connector and one or more simulations failed. In
                    % this case, a NaN (double) will be stored in the
                    % structure causing the failure of vertcat. If the
                    % output is a scalar the vertcat will work with no
                    % issues. Thus, the construction of SimulationData will
                    % just go on and set LisDataseries.
                    if strcmp(ErrorMessage.identifier,'MATLAB:UnableToConvert')
                        Xobj.LisDataseries(n) = true;
                    else
                        % If the error is not because of the vertcat
                        % failure, rethrow the error (it should never
                        % happen)
                        rethrow(ErrorMessage)
                    end
                end
            end

            %3.3.   Send notification to Output
            
        end % end constructor
        
        Xobj=display(Xobj);           % Show report on matlab console
        
        Xobj=plus(Xobj,XsimOut2);    % add SimulationData
        
        Xobj=minus(Xobj,XsimOut2);   % subtract SimulationData
        
        VOut=compute(varargin);             % performe operation on SimulationData
        
        Xobj=addData(Xobj,varargin);  % Add variable to SimulationData
        
        Xobj=merge(Xobj,XsimOut2);    % Merge 2 SimulationData Objects
        
        Xobj=removeData(Xobj,varargin); % Remove data from the SimulatioData Objects
        
        [Mvalues, varargout]=getValues(Xobj,varargin);  % Retrieve values of a specific variable
        
        Cdataseries=getDataseries(Xobj,varargin);  % Retrieve Dataseries of a specific variable
        
        save(Xobj,varargin);               % Save Simulation Output on the disk
        
        [Mstats, Mdata]=getStatistics(Xobj,varargin); % Compute the statistic of the Data
        
        h=plotData(Xobj,varargin);  % plot variables
        
        [Vsupport,Vpdf]=getPDF(Xobj,varargin); % Compute the PDF 
        [Vsupport,Cpdf]=getCDF(Xobj,varargin); % Compute the empirical CDF from samples
        
        function Cnames = get.Cnames(Xobj)
            if isempty(Xobj.Tvalues)
                Cnames={};
            else
                Cnames = fieldnames(Xobj.Tvalues);
            end
        end % Cnames get method
        
        function Nsamples = get.Nsamples(Xobj)
            Nsamples = length(Xobj.Tvalues);
        end % Nsamples get method
        
        function CnamesDataseries = get.CnamesDataseries(Xobj)
            CnamesDataseries =Xobj.Cnames(Xobj.LisDataseries);
        end % Nsamples get method
        
        
    end % End method
    
    methods  (Static)
        XsimOut=load(varargin);
    end
    
end

