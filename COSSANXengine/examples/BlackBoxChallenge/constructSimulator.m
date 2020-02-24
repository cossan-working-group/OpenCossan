function [outputArg1,outputArg2] = constructSimulator(inputArg1,inputArg2)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

specs = inputArg1;
Xpm = inputArg2;

switch lower(specs.SimType)
    case 'mc'
        Xsimulator = MonteCarlo('Nsamples',specs.N,'Nbatches',1);
    case 'ls'
        Nlines = specs.N;
        XlsFD=LocalSensitivityFiniteDifference('Xtarget',Xpm,'Coutputnames',{'Vg'});
        XlsMC=LocalSensitivityMonteCarlo('Xtarget',Xpm,'Coutputnames',{'Vg'});
        XgFD = XlsFD.computeGradient;
    switch lower(specs.grad)
        case 'sns'
            XgSNS=XlsMC.computeGradientStandardNormalSpace;
            Xsimulator = LineSampling('Nlines',Nlines,'Xgradient',XgSNS,'Vset',specs.Vset);
        case  'phy'
            Xgrad = XlsFD.computeGradient;
            Xsimulator = LineSampling('Nlines',Nlines,'Xgradient',Xgrad,'Vset',specs.Vset);
        case 'ind'
            Xlsm=XlsFD.computeIndices;
            Xsimulator=LineSampling('Nlines',Nlines,'XlocalSensitivityMeasures',Xlsm,'Vset',specs.Vset);
    end
    case 'als'
            Xsimulator = AdaptiveLineSampling('Nlines',specs.N);
    case 'ss'
        Xsimulator = SubsetSimulation('Nsamples',specs.N,'Nbatches',1);
end

outputArg1 = Xsimulator;
% outputArg2 = inputArg2;
end

