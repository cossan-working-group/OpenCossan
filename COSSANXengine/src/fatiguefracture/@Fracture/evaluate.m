function Nout = evaluate(Xobj,Tin)
% The covariance function to be evaluated. EVAULATE method accepts a vector x
% and returns a vector Vcov, the covariance function evaluated at x.


%% Check inputs

if ~exist('Tin','var')
   error('openCOSSAN:Fatigue:Fracture',...
         'The evaluation points must be passed to the CrackGrowth function');

end


%% Evaluate function

XsimOut = run(Xobj,Tin);

% keep only the variables defined in the Coutputnames
XsimOut=XsimOut.split('Cnames',Xobj.Coutputnames);

%% Extract values of the objective function

Nout=XsimOut.Mvalues;

if isempty(Nout)
    Nout=XsimOut.getValues('Sname',Xobj.Coutputnames);
end
% 

return
