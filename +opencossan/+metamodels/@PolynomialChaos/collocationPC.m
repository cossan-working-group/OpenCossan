function Xobj = collocationPC(Xobj)
%COLLOCATIONPC
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/collocationPC@PolynomialChaos
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011
% ==================================================================

global OPENCOSSAN
clear global CFEresult

%% Retrieve the input

Xinp         = Xobj.Xsfem.Xmodel.Xinput;                           % Obtain Input

Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Xobj.Norder  = Xobj.Xsfem.Norder;                                  % Obtain order of PC expansion
Xconnector   = Xobj.Xsfem.Xmodel.Xevaluator.CXsolvers{1};
Xext         = Xconnector.CXmembers{2};

%% Calculate the P-C coefficients

Xobj.Npccoefficients = pcnumber(Nrvs,Xobj.Norder);
Mpccoefficients      = zeros(Xext.Nresponse,Xobj.Npccoefficients);

if strcmpi(Xobj.Xsfem.Sbasis,'Hermite')
    OpenCossan.cossanDisp('[PolynomialChaos.collocationPC] Loading the deterministic terms from the P-C database (for Hermite Polynomials)',3);
    
    load(fullfile(OPENCOSSAN.SmatlabDatabasePath,'PCterms','vpsii2_coefficients', ...
        ['vpsii2_coeffs_',num2str(Nrvs),'_',num2str(Xobj.Norder), '.mat']));
    
elseif strcmpi(Xobj.Xsfem.Sbasis,'Legendre')
    OpenCossan.cossanDisp('[PolynomialChaos.collocationPC] Calculating the deterministic terms (for Legendre Polynomials)',3);
    Vpsii2 = psi2Legendre(Nrvs,Xobj.Norder);
end

% specify the options (structure) for the sparse grid toolbox
% Note: Spinterp v5.1.1. is used as the sparse grid toolbox

Toptions   = spset('GridType',Xobj.Xsfem.Sgridtype,'Vectorized','on','MaxDepth',Xobj.Xsfem.Nmaxdepth,...
    'RelTol',Xobj.Xsfem.relativetolerance,'NumberofOutputs',Xext.Nresponse);

% print the selected options for the sparse grid toolbox
OpenCossan.cossanDisp( '[PolynomialChaos.collocationPC] Sparse grid toolbox started with the following options:',3);
OpenCossan.cossanDisp(['[PolynomialChaos.collocationPC] Grid Type          : ' Toptions.GridType],3);
OpenCossan.cossanDisp(['[PolynomialChaos.collocationPC] Relative Tolerance : ' num2str(Toptions.RelTol)],3);
OpenCossan.cossanDisp(['[PolynomialChaos.collocationPC] Max Depth          : ' num2str(Toptions.MaxDepth)],3);
OpenCossan.cossanDisp(['[PolynomialChaos.collocationPC] Range              :[' num2str(Xobj.Xsfem.Vrange) ']' ],3);

Vrange = Xobj.Xsfem.Vrange;
Mrange = repmat(Vrange,Nrvs,1);

% these global variables are defined, because it was necessary to keep
% these parameters in memory
global counter
global Ntotalsimulations
Ntotalsimulations = 0;

for coeffindex=1:Xobj.Npccoefficients
    counter=0;
    OpenCossan.cossanDisp(['[PolynomialChaos.collocationPC] Calculating coefficient ' num2str(coeffindex) '/' num2str(Xobj.Npccoefficients) ' started'],3);
    hCI=@PolynomialChaos.calculateIntegral;
    T = spvals(hCI,Nrvs,Mrange,Toptions,coeffindex,Xobj);
    for iresponse=1:Xext.Nresponse
        Tdummy      = T;
        Tdummy.vals = T.vals(iresponse,:);
        Mpccoefficients(iresponse,coeffindex) = spquad(Tdummy)/Vpsii2(coeffindex);
    end
    OpenCossan.cossanDisp(['[PolynomialChaos.collocationPC] Calculating coefficient ' num2str(coeffindex) '/' num2str(Xobj.Npccoefficients) ' completed'],3);
end


%% Store the PC coefficients in the Object

% NOTE: In collocation the coefficients are calculated only for a single
% DOF, hence Mpccoefficients is always a vector in this case (Npccoefficients x 1)
Xobj.Mpccoefficients         = Mpccoefficients;
Xobj.Xsfem.Ntotalsimulations = Ntotalsimulations;

%% Clear global variables & files

clear counter
clear CFEresult
clear Ntotalsimulations

if Xobj.Xsfem.Lcleanfiles
    OpenCossan.cossanDisp(['[PolynomialChaos.collocationPC] Clean all .sh files in ' Xconnector.Smaininputpath],3);
    delete([Xconnector.Smaininputpath  '*.sh']);
end

return
