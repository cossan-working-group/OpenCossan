function Xsp = AtkinsonSilva(Xsp,varargin)
%ATKINSONSILVA .. short description
%  AtkinsonSilva(SP,varargin)
%
%   USAGE:  Xsp=AtkinsonSilva(StochasticProcess,'PropertyName', PropertyValue, ...)
%
%   The Atkinson Silva method constructs a stochastic process from source
%   spectrum given a magnitude range and a epicentral distance range. The
%   magnitude is modelled as a Gutenberg-Richter distribution and the
%   epicentral distance as a distribution provided by the user.
%
%   MANDATORY ARGUMENTS:
%    - SP       		StochasticProcess object
%    - VMrange  		Range of Magnitude
%    - VRrange  		Range of epicentral distance
%	 - bi 				Gutenberg-Richter paramter
%    - erqkduration		Earthquake duration
% 	 - timestep			Size of the time grid
%
%  Example:
%  SP1 = StochasticProcess('Sdistribution','WhiteNoise','Vcoord',TT); 
%  SP1 =    SP1.AtkinsonSilva('Vgutenbergmagnituderange',[5,8],'parameterGR',bi,'Vequiprobableepicentraldistancerange',[10,50],'soilvs30',310,'erqkduration',75,'timestep',0.01);
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/TBD
%
% Authors: Marco de Angelis and Fabrizio Scozzese
%
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

import opencossan.common.inputs.*
import opencossan.workers.*

OpenCossan.validateCossanInputs(varargin{:})


for k=1:2:length(varargin)
    switch lower(varargin{k})
        
        case {'vgutenbergmagnituderange','vmagnituderange','vmagnitude'}
            Mmin=varargin{k+1}(1);
            Mmax=varargin{k+1}(2);
        case {'vequiprobableepicentraldistancerange','vepicentraldistance','vdistance'}
            Rmin=varargin{k+1}(1);
            Rmax=varargin{k+1}(2);
        case {'parametergr','parametergutembergr','parameter'}
            bi=varargin{k+1};
        case {'soilvs30'}
            VS=varargin{k+1};
        case {'erqkduration'}
            Tmax=varargin{k+1};
        case {'timestep'}
            dt=varargin{k+1};
        otherwise
            error('openCOSSAN:StochasticProcess:AtkinsonSilva',...
                ['Field name ' varargin{k} ' not allowed']);
    end
end

Xsp.SearthquakeModel = 'atkinsonsilva';

XMmin = Parameter('value',Mmin);
XMmax = Parameter('value',Mmax);
XRmin = Parameter('value',Rmin);
XRmax = Parameter('value',Rmax);
XVS = Parameter('value',VS);
XTmax = Parameter('value',Tmax);
Xdt = Parameter('value',dt);
XJ   =  Parameter('value',3);
Xbi = Parameter('value',bi);


XrvM = RandomVariable('Sdistribution','uniform','lowerBound',0.0,'upperBound',1);
XrvR = RandomVariable('Sdistribution','uniform','lowerBound',0.0,'upperBound',1);
TT=(0:dt:Tmax);

Xrvset = RandomVariableSet('Cmembers',{'XrvM','XrvR'},'CXrv',{XrvM, XrvR});

Xsp0 = StochasticProcess('Sdistribution','WhiteNoise','Vcoord',TT);

Xinput_AS_GM=Input('CXmembers',{XMmin XMmax XRmin XRmax XVS XTmax Xdt XJ Xbi Xsp0 Xrvset},...
    'CSmembers',{'XMmin' 'XMmax' 'XRmin' 'XRmax' 'XVS' 'XTmax' 'Xdt' 'XJ' 'Xbi' 'Xsp0' 'Xrvset'});

SatkinsonSilvapath=fullfile(OpenCossan.getCossanRoot,'src','+common','+utilities');

Xmio_AS_GM = Mio('Sfile', 'miofun_atkinsonsilva',...
    'Spath',SatkinsonSilvapath,...
    'CinputNames',{'XMmin' 'XMmax' 'XRmin' 'XRmax' 'XVS' 'XTmax' 'Xdt' 'XJ' 'Xbi' 'XrvM' 'XrvR' 'Xsp0'},...
    'CoutputNames',{'ground_acc'},...
    'Lfunction',true,...
    'Sformat','structure');

Xsp.CXatkinsonSilva={Xinput_AS_GM,Xmio_AS_GM};
