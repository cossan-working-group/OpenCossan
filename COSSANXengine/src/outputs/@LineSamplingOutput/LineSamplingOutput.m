classdef LineSamplingOutput < SimulationData
    %LINESAMPLINGOUTPUT class containing speific outputs of the
    %LineSampling simulation method
    %
    %	MANDATORY ARGUMENTS:
    %	====================
    %   NONE
    %
    %   OPTIONAL ARGUMENTS:
    %   ====================
    %   - SperformanceFunctionName: name of the output of the
    %   PerformanceFunction related to the simulation (or name of the
    %     output of the model if no PerformanceFunction is defined)
    %   - VnumPointLine: array containing the number of points on each line
    %
    %   OUTPUT ARGUMENT:
    %   Xrv: LineSamplingOutput object
    %
    %
    %   USAGE
    %   ====================
    %   Xlso3 =
    %   LineSamplingOutput('sperformancefunctionname','Vg2','vnumpointline' ,[2 3 4 5]')
    % ==================================================================
    % COSSAN-X - The next generation of the computational stochastic analysis
    % University of Innsbruck, Copyright 1993-2011 IfM
    % ==================================================================
    
    properties (SetAccess = protected)
        SperformanceFunctionName % name of the output of the PerformanceFunction
        VdistancePlane           % Evaluation point along the line (distance 
                                 % from the hyper-plane orthogonal to the 
                                 % important direction)
        VdistanceOrigin          % distance from the origin in SNS
        VnumPointLine            % # of points on each line
%         XsimulationData
    end
    
    properties (Dependent = true, SetAccess = protected)
        Nlines                   % Number of Lines
        Npoints                  % Total number of points
    end
    
    
    methods
        
        function Xobj=LineSamplingOutput(varargin)
            %LINESAMPLINGOUTPUT
            % This object stores the results of the simulation performed by
            % LineSampling
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/@LineSamplingOutput
            %
            % Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
            % Author: Edoardo Patelli

            OpenCossan.validateCossanInputs(varargin{:});
            % Initialize variables
            Vpoints=[];
            Sname=[];
            Vindex=[];

            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sperformancefunctionname'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        Sname = varargin{k+1};
                    case {'vnumpointline'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        % the field SoutputName is always a column vector
                        if isrow(varargin{k+1})
                            Vpoints = varargin{k+1}';
                        else
                            Vpoints = varargin{k+1};
                        end
                    case {'vnorm','vdistance','vdistanceorigin'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VdistancePoint = varargin{k+1}; 
                    case {'vdistanceorthogonalplane'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VdistanceOrthPlane = varargin{k+1};
                        if isrow(VdistanceOrthPlane)
                            VdistanceOrthPlane=VdistanceOrthPlane';
                        end
                    case {'xsimulationdata'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        XsimOut=varargin{k+1};
                    otherwise
                        error('openCOSSAN:LineSamplingOutput',...
                            'PropertyName %s not allowed', varargin{k})
                end
            end % for k
            
            varargin(Vindex)=[];
            % Call constructor superclass
            Xobj=Xobj@SimulationData(varargin{:});
            
            Xobj.SperformanceFunctionName=Sname;
                        
            Xobj.VnumPointLine=Vpoints;
            
%             Xobj.XsimulationData=XsimOut;
            
            %% Validate Object
            Ntotalpoints=Xobj.Npoints; 

            if exist('VdistanceOrthPlane','var')
                Xobj.VdistancePlane=VdistanceOrthPlane;
                     assert(length(Xobj.VdistancePlane)==Ntotalpoints,...
                'openCOSSAN:LineSamplingOutput',...
                'Number of points in VdistanceOrthogonalPlane is %i and it should be %i!',...
                length(Xobj.VdistancePlane),Ntotalpoints);
            end
            
            if exist('VdistancePoint','var')
                Xobj.VdistanceOrigin=VdistancePoint;
                 assert(length(Xobj.VdistanceOrigin)==Ntotalpoints,...
                'openCOSSAN:LineSamplingOutput',...
                'Number of points in VdistanceOrigin is %i and it should be %i!',...
                length(Xobj.VdistanceOrigin),Ntotalpoints);
            end
            
            
            % Merge XsimOut with the current object
            if exist('XsimOut','var')
                Xobj=Xobj.merge(XsimOut);
            end
            
        end % end constructor
        
        % Dependent properties
        function Nlines = get.Nlines(Xobj)
            Nlines = length(Xobj.VnumPointLine);
        end
        
                % Dependent properties
        function Npoints = get.Npoints(Xobj)
            Npoints =sum(Xobj.VnumPointLine);
        end
        
        function save(Xobj,varargin)
            % Calling superclass method
            save@SimulationData(Xobj,varargin{:})
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            %% Check Inputs
            for k=1:2:nargin-1
                switch lower(varargin{k})
                    case {'sfilename'}
                        %check input
                        SfileName = varargin{k+1};
                        
                end
            end
            LineSamplingReserved_SperformanceFunctionName=Xobj.SperformanceFunctionName; %#ok<NASGU>
            LineSamplingReserved_VnumPointLine=Xobj.VnumPointLine; %#ok<NASGU>
            LineSamplingReserved_Vdistance=Xobj.VdistanceOrigin; %#ok<NASGU>
            LineSamplingReserved_VdistancePlane=Xobj.VdistancePlane; %#ok<NASGU>
            save(SfileName,'LineSamplingReserved_SperformanceFunctionName', ...
                'LineSamplingReserved_VnumPointLine', ...
                'LineSamplingReserved_VdistancePlane', ...
                'LineSamplingReserved_Vdistance','-append')
            
            
        end
        
        Xobj = merge(Xobj,Xobj2)
        
        varargout=plotLines(Xobj,varargin)
        
    end % Methods
    
    methods  (Static)
        function XLineSamplingOutput=load(varargin)
            % Calling superclass method
            Xout=load@SimulationData(varargin{:});
            
            %% Check Inputs
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sfilename'}
                        %check input
                        SfileName = varargin{k+1};
                end
            end
            
            load(SfileName,'LineSamplingReserved_*');
            
            if isempty(LineSamplingReserved_VnumPointLine)
                XLineSamplingOutput=LineSamplingOutput('XsimulationData',Xout, ...
                    'SperformanceFunctionName',LineSamplingReserved_SperformanceFunctionName);
            else
                XLineSamplingOutput=LineSamplingOutput('XsimulationData',Xout, ...
                    'VnumPointLine',LineSamplingReserved_VnumPointLine, ...
                    'Vdistanceorthogonalplane',LineSamplingReserved_VdistancePlane, ...
                    'Vdistance',LineSamplingReserved_Vdistance, ...
                    'SperformanceFunctionName',LineSamplingReserved_SperformanceFunctionName);
            end
            
        end
    end
    
end

