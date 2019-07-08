 classdef UserDefRandomVariable < RandomVariable
    %USERDEFRANDOMVARIABLE is a subclass of RANDOMVARIABLE. This class creates
    %user defined random variables.
    %
    % See Also:
    % http://cossan.cfd.liv.ac.uk/wiki/index.php/@Connector
    
    %  Copyright 1993-2011, COSSAN Working Group
    %  University of Innsbruck, Austria
    
    properties (SetAccess=private)
        Sdefinition % Define how the Object is created
        Xfunction   % Store a Function object used to define the pdf/cdf
        Sfunction   % 'ecdf'    (default) to use an interpolated empirical cdf, defined
%                 at the data values as the midpoints in the vertical steps
%                 in the ecdf, and computed by linear interpolation between
%                 data values; 'kernel'  to use a kernel smoothing estimate
%                 of the cdf and interpolate between a discrete set of
%                 these estimated values 
        Vtails      % Store the Data values provided by the user
        empirical_distribution % approximate pdf and cdf, based on the available data
    end
    
    properties (SetAccess=private,Hidden)
        NsampleFit=1000;    % samples used to estimate mean and std of the UserDefRandomVariable
        NsupportPoints=100; % Number of points used to estimated the cdf/pdf
    end
    
    properties (Dependent)
        Vsupport   % samples used to estimate mean and std of the UserDefRandomVariable
        Vcdf       % Values of the cdf at the support points
        Vpdf       % Values of the pdf at the support points
    end
    
    methods
        %% constructor
        function Xobj=UserDefRandomVariable(varargin)
            %USERDEFRANDOMVARIABLE is a subclass of RANDOMVARIABLE. This class creates
            %user defined random variables.
            %
            %
            % See Also:
            % http://cossan.cfd.liv.ac.uk/wiki/index.php/@Connector
            if isempty(varargin) % create an empty object
                return;
            end
            %  Copyright 1993-2011, COSSAN Working Group
            %  University of Innsbruck, Austria
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Remove predefined distribution
            Xobj.Sdistribution='USER-DEFINED';
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'vcdf'}
                        Xobj.Vdata(:,2)=varargin{k+1};
                        Xobj.Sdefinition ='CDF';
                    case {'vpdf'}
                        Xobj.Vdata(:,2)=varargin{k+1};
                        Xobj.Sdefinition ='PDF';
                    case {'xcdf'}
                        Xobj.Xfunction=varargin{k+1};
                        Xobj.Sdefinition ='CDF';
                    case {'xpdf'}
                        Xobj.Xfunction=varargin{k+1};
                        Xobj.Sdefinition ='PDF';
                    case {'xfunction'}
                        Xobj.Xfunction=varargin{k+1};
                    case {'sfunction'}
                        Xobj.Sfunction =varargin{k+1};
                    case {'vdata'}
                        assert(max(size(varargin{k+1}))>2,...
                            'openCOSSAN:UserDefRandomVariable',...
                            'Vdata must be a vector at least three elements');
                        if size(varargin{k+1},1)>1
                            Xobj.Vdata(:,1)=varargin{k+1};
                        else
                            Xobj.Vdata(:,1)=varargin{k+1}';
                        end
                    case {'mdata'}
                        
                        if size(varargin{k+1},1)>2
                            Xobj.Vdata=varargin{k+1};
                        else
                            Xobj.Vdata=varargin{k+1}';
                        end
                        
                        % Check support points are unique
                        assert(logical(length(unique(Xobj.Vdata(:,1)))==length(Xobj.Vdata(:,1))),...
                            'openCOSSAN:UserDefRandomVariable', 'The support points must be unique')
                        
                        assert(max(size(varargin{k+1}))>2,...
                            'openCOSSAN:UserDefRandomVariable',...
                            'Values after PropertyName %s must be a vector at least three elements',varargin{k});

                    case {'vtails'}
                        % check  std>=0
                        if length(varargin{k+1}) ~= 2
                            error('openCOSSAN:rv:userdefined',...
                                'Vtails must be a vector containing two doubles');
                        end
                        Xobj.Vtails=(varargin{k+1});
                        if Xobj.Vtails(1) > Xobj.Vtails(2)
                            error('openCOSSAN:rv:userdefined','Vtails must be a vector whose 1st element is less than the 2nd element');
                        elseif  Xobj.Vtails(1) <0
                            error('openCOSSAN:rv:userdefined','The first element of vtails must be bigger than zero');
                        elseif Xobj.Vtails(2) >1
                            error('openCOSSAN:rv:userdefined','The 2nd element of vtails must be less than one');
                        end
                    case {'sample', 'inisample','parameter1','par1'}
                        Xobj.Cpar{1,1}='par1';
                        Xobj.Cpar{1,2}=varargin{k+1};
                    case {'markovchains','nmarkovchains','parameter2','par2'}
                        Xobj.Cpar{2,1}='par2';
                        Xobj.Cpar{2,2}=varargin{k+1};
                    case {'vdeltaxi','parameter3','par3'}
                        Xobj.Cpar{3,1}='par3';
                        Xobj.Cpar{3,2}=varargin{k+1};
                    case 'sdefinition'
                        Xobj.Sdefinition = varargin{k+1};
                end
            end
            
            
            if isempty(Xobj.Sdefinition)
                % Detect the kind of distribution automatically
                if size(Xobj.Vdata,2)==1
                    Xobj.Sdefinition='REALIZATIONS';
                else
                    if issorted(Xobj.Vdata(:,2)) && abs(Xobj.Vdata(end,2)-1)<eps
                        Xobj.Sdefinition='CDF';
                    else
                        pdfArea=trapz(Xobj.Vdata(:,1),Xobj.Vdata(:,2));
                        if pdfArea<1+eps && pdfArea>1-eps
                            Xobj.Sdefinition='PDF';
                        else
                            % Check that cdf is not descreasing
                            
                            error('openCOSSAN:UserDefRandomVariable',...
                                ['The data type can not be recongized. ' ...
                                'Check if: \n*the pdf is normalized (current value %d' ...
                                ').\n*the cdf is not descrasing.'],pdfArea)
                        end
                    end
                end
            end
            
            switch Xobj.Sdefinition
                case 'CDF'
                    Xobj=cdfun(Xobj);
                case 'PDF'
                    Xobj=pdfun(Xobj);
                case 'REALIZATIONS'
                    Xobj=realizations(Xobj);
                otherwise
                    error('openCOSSAN:UserDefRandomVariable',...
                        'The Sdefinition type can not be %s,',Xobj.Sdefinition)
            end
            
        end % end constructor
        
        % Other methods
        
        display(Xobj);
        
        Xobj=evalpdf(Xobj,VX);
        
        Xobj=map2physical(Xobj,VU);
        Xobj=map2stdnorm(Xobj,VX);
        
        Xobj=sample(Xobj,varargin);
        
        VU = physical2cdf(Xrv,VX)
        VX = cdf2physical(Xrv,VU)
        
        
        function Vx=getPdf(Xrv,varargin)
            % Redirect method defined in the superclass
            Vx = Xrv.Vpdf;
        end
        
        % Dependent fields
        
        function Vsupport=get.Vsupport(Xobj)
            % Get support points
            bound=1.1; % add 10%
            minBound=bound*Xobj.empirical_distribution.icdf(0.01);
            maxBound=bound*Xobj.empirical_distribution.icdf(0.99);
            Vsupport=linspace(minBound,maxBound,Xobj.NsupportPoints);
        end
        
        function Vpdf=get.Vpdf(Xobj)
            % Get pdf values of the distribution
            Vpdf=Xobj.empirical_distribution.pdf(Xobj.Vsupport);
        end
        
        function Vcdf=get.Vcdf(Xobj)
            % Get pdf values of the distribution
            Vcdf=Xobj.empirical_distribution.cdf(Xobj.Vsupport);
        end
        
        
    end
    
    methods (Access=private)
        Xobj=cdffun(Xobj);
        Xobj=pdfun(Xobj);
        Xobj=realizations(Xobj);
        Xobj=checkDistribution(Xobj);
    end
    
    methods(Static)
        VU = stdnorm2cdf(VX)
        VX = cdf2stdnorm(VU)
    end
    
    
    
end

