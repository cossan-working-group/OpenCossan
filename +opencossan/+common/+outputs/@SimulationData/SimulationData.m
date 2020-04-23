classdef SimulationData
    %SIMULATIONDATA Class definition of the SimulationData object
    %
    % See Also: Also: http://cossan.co.uk/wiki/index.php/@SimulationData
    
    properties
        Sdescription        % Description of the object
        SexitFlag           % Description of the termination criteria
        SbatchFolder        % Store the batch name of the batch folder
        TableValues=table   % Store data in a table format
    end
    
    properties (Dependent = true, SetAccess = private)
        Cnames           % Names of the variables present in the object
        CnamesDataseries % Extract the names of dataseries
        Nsamples         % Number of samples
        NmissingData    % number of missing data
    end
    
    properties (SetAccess=private)
        LisDataseries   % flag for dataseries
    end
    
    methods
        % SIMULATIONDATA This method constructs a SimulationData object. The
        % object is used to store the results of the simulation.
        %
        % See Also: http://cossan.co.uk/wiki/index.php/@SimulationData
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
            
            if nargin == 0
                return
            end
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'table'}
                        Xobj.TableValues=varargin{k+1};
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
                        Mvalues=varargin{k+1};
                    case {'sbatchfolder'}
                        Xobj.SbatchFolder=varargin{k+1};
                    otherwise
                        error('openCOSSAN:SimulationData:wrongArgument', ...
                              'PropertyName %s is not allowed',varargin{k});
                end
            end
            
            % Construct SimulationData from a matrix
            if exist('Cnames','var')
                assert(logical(exist('Mvalues','var')),'openCOSSAN:SimulationData:NoValues', ...
                       'It is mandatory to pass Mvalue field if the Cnames are defined');
                
                assert(length(Cnames)==size(Mvalues,2),...
                   'openCOSSAN:SimulationData:WrongSizeMvalue', ...
                     ['The number of variable defined in Cvariablenames (%i)' ...
                       ' does not match with the number of columns of Mvalues (%i).',...
                       length(Cnames),size(Mvalues,2)]);                
                
                % Construct table object
                Xobj.TableValues = array2table(Mvalues,'VariableNames',Cnames);
            end

            
            % Store output type
            
            Xobj.LisDataseries=false(length(Xobj.Cnames),1);
            for n=1:length(Xobj.Cnames);
                try
                    Xobj.LisDataseries(n)=isa(vertcat(Xobj.TableValues.(Xobj.Cnames{n})),'Dataseries');
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
        
        VOut=compute(varargin);       % performe operation on SimulationData
        
        Xobj=addData(Xobj,varargin);  % Add variable to SimulationData
        
        Xobj=merge(Xobj,XsimOut2);    % Merge 2 SimulationData Objects
        
        Xobj=removeData(Xobj,varargin); % Remove data from the SimulatioData Objects
        
        [Mvalues, varargout]=getValues(Xobj,varargin);  % Retrieve values of a specific variable
        
        Cdataseries=getDataseries(Xobj,varargin);  % Retrieve Dataseries of a specific variable
        
%        save(Xobj,varargin);               % Save Simulation Output on the disk
        
        [Mstats, Mdata]=getStatistics(Xobj,varargin); % Compute the statistic of the Data
        
        h=plotData(Xobj,varargin);  % plot variables
        
        function Cnames = get.Cnames(Xobj)
            Cnames=Xobj.TableValues.Properties.VariableNames;
        end % Cnames get method
        
        function Nsamples = get.Nsamples(Xobj)
            Nsamples = height(Xobj.TableValues);
        end % Nsamples get method
        
        function CnamesDataseries = get.CnamesDataseries(Xobj)
            CnamesDataseries =Xobj.Cnames(Xobj.LisDataseries);
        end % Nsamples get method        
        
        function NmissingData = get.NmissingData(Xobj)
            NmissingData =sum(sum(ismissing(Xobj.TableValues)));
        end % Nsamples get method
        
        
    end % End method
    
    methods  (Static)
        % The method load should be used only to convert old SimulationData
        % object in the new format
        XsimOut=load(varargin);
    end
    
end

