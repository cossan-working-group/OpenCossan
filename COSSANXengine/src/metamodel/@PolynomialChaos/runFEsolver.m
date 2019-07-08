function CFEresult = runFEsolver(Xpc,Mxi)
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/runFEsolver@PolynomialChaos   
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 
% $Author:~Murat~Panayirci$ 

global Ntotalsimulations

%% get the input

[Nruns Nrvs]  = size(Mxi);
Xsfem         = Xpc.Xsfem;
Xinp          = Xsfem.Xmodel.Xinput;                                % Obtain Input

assert(length(Xinp.CnamesRandomVariableSet)==1,'COSSAN:PolynomialChaos:runFEsolver', ...
    'Only 1 random variable set is allowed')

Crvnames      = Xinp.CnamesRandomVariable;                          % Obtain RV names
Nrvs          = Xinp.NrandomVariables;                                   % Obtain No of RVs
Vmeanvalues   = get(Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1}),'members','mean');                         % Obtain mean values of each RV
Vstdvalues    = get(Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1}),'members','std');                          % Obtain std dev values of each RV


%% Prepare injector for xi values

% first prepare the Tinput to be injected for all samples 
for jrun=1:Nruns
    Ntotalsimulations = Ntotalsimulations + 1;
    for krvno=1:Nrvs
        value = Vmeanvalues(krvno) + Mxi(jrun,krvno)*Vstdvalues(krvno); %#ok<*NASGU>     
        eval([ 'Tinput(jrun).' Crvnames{krvno} ' = value ;' ]);
    end
end

%% Perform the simulations 

Xout = Xsfem.Xmodel.apply(Tinput);

for jrun=1:Nruns
    for iresponse = 1:Xsfem.Xmodel.Xevaluator.CXsolvers{1}.CXmembers{2}.Nresponse
        CFEresult{jrun}(iresponse,1) = Xout.Tvalues(jrun).(Xsfem.Xmodel.Xevaluator.CXsolvers{1}.CXmembers{2}.Xresponse(iresponse).Sname); %#ok<*AGROW>
    end
end


return
