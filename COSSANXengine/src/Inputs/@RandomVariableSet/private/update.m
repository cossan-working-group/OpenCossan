function Xrvset = update(Xrvset)
%UPDATE This method updates the covariance matrix of the RandomVariableSet
%
%  Usage:  Xrvset=update(Xrvset)
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/@RandomVariableSet
%
% Copyright 1993-2011, COSSAN Working Group, University of Innsbruck, Austria


% Get Standard Deviation of the RandomVariables
Vstd = get(Xrvset,'Cmembers','std');

% Perform update
if Xrvset.Lindependence
    % Reset correlation matrix
   Xrvset.Mcorrelation = sparse(1:Xrvset.Nrv,1:Xrvset.Nrv,1);
   Xrvset.Mcovariance = Vstd * Vstd' .* Xrvset.Mcorrelation;
else
    % make correlation matrix sparse
   if ~issparse(Xrvset.Mcorrelation)
       Xrvset.Mcorrelation=sparse(Xrvset.Mcorrelation);
   end
   Xrvset.Mcovariance = Vstd * Vstd' .* Xrvset.Mcorrelation;
   % Compute NATAF model
   Xrvset = natafTransformation(Xrvset);
end



