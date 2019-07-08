function Xobj = large_II(Xobj)
%SMALL_I compute missing parameters (if is possible) of the small I
%distribution 
%
% Input/Output is the structure of the random variable

Xobj.Sdistribution='LARGE-II';

Xobj.Cpar{1,1} = 'shape';
Xobj.Cpar{2,1} = 'scale';

assert(~isempty(Xobj.Cpar{1,2}) && ~isempty(Xobj.Cpar{2,2}),...
    'openCOSSAN:RandomVariable:binomial','Large-II distribution can be defined only via parameters');

assert(Xobj.Cpar{1,2}>0,'openCOSSAN:RandomVariable:large_II','Parameter ''shape'' must be greater than zero.')
assert(Xobj.Cpar{2,2}>0,'openCOSSAN:RandomVariable:large_II','Parameter ''scale'' must be greater than zero.')

if ~isempty(Xobj.Vdata)
            error('openCOSSAN:RandomVariable:large_II',...
            'Vdata is not available for large_II distribution');
end

% computes mean and variance from the parameters. If shape <=1 the first
% and second moment do not exist. If shape <=2 the second moment does not
% exist.
Xobj.mean = inf;
Xobj.std = inf;
if Xobj.Cpar{1,2}>1
    Xobj.mean = Xobj.shift + Xobj.Cpar{2,2} * gamma(1 - 1/Xobj.Cpar{1,2});
end
if Xobj.Cpar{1,2}>2
    variance =  Xobj.Cpar{2,2}^2 *( gamma(1 - 2/Xobj.Cpar{1,2}) - (gamma(1 - 1/Xobj.Cpar{1,2}))^2 );
    Xobj.std = sqrt(variance);
end
Xobj.lowerBound = Xobj.shift;