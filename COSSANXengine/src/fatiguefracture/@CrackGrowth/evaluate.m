function dadn = evaluate(Xobj,Tin)
% The covariance function to be evaluated. EVAULATE method accepts a vector x
% and returns a vector Vcov, the covariance function evaluated at x.


%% Check inputs

if ~exist('Tin','var')
   error('openCOSSAN:Fatigue:CrackGrowth',...
         'The evaluation points must be passed to the CrackGrowth function');

end


%% Evaluate function

XsimOut = run(Xobj,Tin);

% keep only the variables defined in the Coutputnames
XsimOut=XsimOut.split('Cnames',Xobj.Coutputnames);

%% Extract values of the objective function

dadn=XsimOut.Mvalues;

if isempty(dadn)
    dadn=XsimOut.getValues('Sname',Xobj.Coutputnames);
end
% 

if size(dadn,1)== 1 && size(dadn,2) ~= 1
    dadn=dadn';
end

return
