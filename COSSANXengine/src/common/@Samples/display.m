function display(Xobj)
%DISPLAY   Displays Samples object information
%  DISPLAY(Xobj)
%
%  See also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Samples
% Author: Edoardo Patelli, Matteo Broggi, Marco de Angelis
%
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

%%   Output to Screen
%  Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([ class(Xobj) ' Object - Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp (['Nsamples   = ' num2str(Xobj.Nsamples)],1)
OpenCossan.cossanDisp (['Nvariables = ' num2str(length(Xobj.Cvariables))],1)

if isempty(Xobj.MsamplesHyperCube)
    OpenCossan.cossanDisp('* No samples for Random Variables present',1)
else
    OpenCossan.cossanDisp('-----------------------------------------------------------')
    OpenCossan.cossanDisp ('Samples in the Physical Space ',2)
    Nsamples    = min(5,size(Xobj.MsamplesHyperCube,1));
    CnamesRV=Xobj.CnamesRandomVariable;
    for irv=1:min(length(CnamesRV),10)
        Sstring     = [CnamesRV{irv} ': ' sprintf('%10.3e',Xobj.MsamplesPhysicalSpace(1:Nsamples,irv))];
        if size(Xobj.MsamplesHyperCube,1)>5,
            Sstring     = [Sstring ' ...']; %#ok<AGROW>
        end
        OpenCossan.cossanDisp(Sstring,2);
    end
end

%% Summary for DesignOfExperiments
if isempty(Xobj.MdoeDesignVariables)
    OpenCossan.cossanDisp('* No design of experiments for Design Variables present',1)
else
    OpenCossan.cossanDisp('-----------------------------------------------------------')
    OpenCossan.cossanDisp ('Design of experiments ',2)
    Nsamples    = min(5,size(Xobj.MdoeDesignVariables,1));
    for irv=1:min(length(Xobj.CnamesDesignVariables),10)
        Sstring     = [Xobj.CnamesDesignVariables{irv} ': ' sprintf('%10.3e',Xobj.MdoeDesignVariables(1:Nsamples,irv))];
        if size(Xobj.MdoeDesignVariables,1)>5,
            Sstring     = [Sstring ' ...']; %#ok<AGROW>
        end
        OpenCossan.cossanDisp(Sstring,2);
    end
end

%% Summary of the stochasticprocess
if isempty(Xobj.Xdataseries)
    OpenCossan.cossanDisp('* No stochastic process defined',1)
else
    OpenCossan.cossanDisp('-----------------------------------------------------------',2)
    OpenCossan.cossanDisp ('Stochastic process ',2)
    for n=1:length(Xobj.XstochasticProcess)
        Nsamples=min(5,size(Xobj.Xdataseries,1));
        NlengthDataseries = min(5,size(Xobj.XstochasticProcess{n}.Mcoord,2));
        OpenCossan.cossanDisp([Xobj.CnamesStochasticProcess{n} ':'])
        for icoord = 1:length(Xobj.XstochasticProcess{n}.CScoordinateNames)
            OpenCossan.cossanDisp([Xobj.XstochasticProcess{n}.CScoordinateNames{icoord} ' : '...
                sprintf(' %10.3e',Xobj.XstochasticProcess{n}.Mcoord(icoord,1:NlengthDataseries)') ' ...'])
        end
        for isamples=1:Nsamples
            Vdata = Xobj.Xdataseries(isamples,n).Vdata;
            OpenCossan.cossanDisp(['sample ' num2str(isamples) ' :' ...
                sprintf(' %10.3e',Vdata(1:NlengthDataseries)) ' ...'],2)
        end
        if Nsamples < size(Xobj.Xdataseries,1)
            OpenCossan.cossanDisp('sample ... ',2);
        end
    end
end

%% Summary of BoundedSet
if isempty(Xobj.MsamplesUnitHypercube)
    OpenCossan.cossanDisp('* No samples for Interval Variables present',1)
else
    OpenCossan.cossanDisp('-----------------------------------------------------------')
    OpenCossan.cossanDisp ('Samples in the Epistemic Space ',2)
    Nsamples    = min(5,size(Xobj.MsamplesUnitHypercube,1));
    CnamesRV=Xobj.CnamesIntervalVariable;
    for iiv=1:min(length(CnamesRV),10)
        Sstring     = [CnamesRV{iiv} ': ' sprintf('%10.3e',Xobj.MsamplesEpistemicSpace(1:Nsamples,iiv))];
        if size(Xobj.MsamplesUnitHypercube,1)>5,
            Sstring     = [Sstring ' ...']; %#ok<AGROW>
        end
        OpenCossan.cossanDisp(Sstring,2);
    end
end

