function Vcov = evaluate(Xobj,MX)
% The covariance function to be evaluated. EVAULATE method accepts a matrix x
% and returns a vector Vcov, the covariance function evaluated at x.


%% Check inputs

if ~exist('MX','var')
   error('openCOSSAN:Input:CovarianceFunction',...
         'The evaluation points must be passed to the covariance function');
end

if mod(size(MX,1),2)~=0 
   error('openCOSSAN:Input:CovarianceFunction',...
         ['The number of rows of the passed matrix MX must be a multiple of 2, ' ...
          'where this multiple is equal to the dimension of the input variables']);
end 

%% Prepare input 
Cnames=Xobj.Cinputnames;                                                                                                                           

if size(MX,1) == 2
    % if it is a mono-dimensional SP
    Ctemp = num2cell(MX)';
else
    % split the matrix with the combined input in two sub-matrices, then
    % convert them to cell array
    Ctemp = [num2cell(MX(1:size(MX,1)/2,:),1);num2cell(MX(size(MX,1)/2+1:size(MX,1),:),1)]';
end

Tinput = cell2struct(Ctemp,Cnames,2);

%% Evaluate function

XsimOut = run(Xobj,Tinput);

% keep only the variables defined in the Coutputnames
XsimOut=XsimOut.split('Cnames',Xobj.Coutputnames);

%% Extract values of the objective function
% The objective function should contain only 1 value in the field
% Coutputnames

Vcov=XsimOut.Mvalues;

if isempty(Vcov)
    Vcov=XsimOut.getValues('Cnames',Xobj.Coutputnames);
end

return
