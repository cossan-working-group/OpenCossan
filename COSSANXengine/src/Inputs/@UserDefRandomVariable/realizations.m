function Xobj = realizations(Xobj)
%USERDEFINED compute missing parameters (if is possible) of the userdefined
%                       distribution
% Input/Output is the structure of the random variable

%checks
if isempty(Xobj.Vdata) 
    error('openCOSSAN:rv:userdefined', ...
          'Experimental data are required to construct a UserDefRandomVariable object.');
end

% Set default name of the distribution
Xobj.Sdistribution = 'REALIZATIONS';

if isempty(Xobj.Vtails)
    Xobj.Vtails = [.1 .9];
end   

%build the piecwisedistribution 
Xobj.empirical_distribution = paretotails(Xobj.Vdata, min([Xobj.Vtails]),max([Xobj.Vtails]));

% approximate the mean and std
Xobj.mean = mean(Xobj.Vdata); 
Xobj.std  = std(Xobj.Vdata);


