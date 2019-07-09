function Vx = sample(Xobj,varargin)
%SAMPLE This method produces samples of a the DesingVariable
%
%
%
%  Usage: Vx=SAMPLE(Xdv,'Nsamples',10)
%
%  See also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/Sample@DesignVariable
%
%   Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
%   Author: Edoardo-Patelli

opencossan.OpenCossan.validateCossanInputs(varargin{:});

%TODO: use new input parser
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'nsamples'} % Define the number of samples
            Nsamples = varargin{k+1};
        case {'vbounds'} % Flag to add the bounds
            VuserBounds = varargin{k+1};
        case {'perturbation'} % Flag to perturbation around currect value
            perturbation = varargin{k+1};
        otherwise
            error('openCOSSAN:DesignVariable:sample',...
                'Option %s not implemented',varargin{k})
    end
end


if ~isempty(Xobj.Vsupport)
    if exist('VuserBounds','var')
        warning('openCOSSAN:DesignVariable:sample',...
            'UserDefine bounds can not be used with discrete DesignVariable')
    end
    Vx = Xobj.Vsupport(random('unid',length(Xobj.Vsupport),Nsamples,1));
elseif exist('VuserBounds','var')
    Vx=random('uniform',VuserBounds(1),VuserBounds(2),Nsamples,1);
else
    
    if isfinite(Xobj.lowerBound) && isfinite(Xobj.upperBound)
        Vx=random('uniform',Xobj.lowerBound,Xobj.upperBound,Nsamples,1);
    else
        assert(logical(exist('perturbation','var')),...
            'openCOSSAN:DesignVariable:sample',...
            'perturbation parameter is required to generate samples from design variable with an infinite support')
        Vx=random('uniform',Xobj.value*(1-perturbation),Xobj.value*(1+perturbation),Nsamples,1);       
    end
end

