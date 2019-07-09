function [tableOutput] = evaluate(Xobj,Pinput)
%apply
%
%   This method applies the PolyharmonicSplines over an Input object
%
%
% See Also: http://cossan.co.uk/wiki/index.php/evaluate@PolyharmonicSplines
%
% Author: Edoardo Patelli
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

import opencossan.common.outputs.SimulationData

%%  Check that ResponseSurface has been trained
assert(Xobj.Lcalibrated,'openCOSSAN:PolyharmonicSplines:apply',...
    'PolyharmonicSplines has not been calibrated');

%%  Process input
Minputs=table2array(Pinput);


%%  Evaluate splines

% auxiliary variables
Nsamples = size(Minputs,1);
Ndim = size(Xobj.Mcenters,2);
Ncenters = size(Xobj.Mcenters,1);

XSimDataInput=SimulationData('Sdescription','Simulation Output from ResponseSurface',...
    'Table',Pinput);

% initialize the matrix that will contain the estimated outputs
Moutput=zeros(height(Pinput),length(Xobj.OutputNames));

for iresponse = 1:length(Xobj.OutputNames)
    % compute the relative distance between the evaluation points and each center
    Mdist = zeros(Nsamples,Ncenters);
    for idim = 1:Ndim
        Mdist = Mdist + bsxfun(@minus,Minputs(:,idim),Xobj.Mcenters(:,idim)').^2;
    end
    Mdist = sqrt(Mdist);
    
    % apply the desired polyharmonic base function
    if bitget(double(Xobj.Nexponent), 1) %very fast check if integer is odd or even
        Mdist = Mdist.^Xobj.Nexponent;
    else
        % if there are points coincidents with the centers, the distance
        % will be zero. The logarithm will return NaN as an output, but we 
        % know that the output we want is 0)
        Mdist = Mdist.^Xobj.Nexponent.*log(Mdist);
        % put a zero instead of the NaNs (all the points with identical
        % coordinates)
        Mdist(isnan(Mdist)) = 0; 
    end
    
    Moutput(:,iresponse) =sum(repmat(Xobj.CVsplinesCoefficients{iresponse}',Nsamples,1).*Mdist,2) +...
        x2fx(Minputs,Xobj.SextrapolationType)*Xobj.CVpolyCoefficients{iresponse};
end


tableOutput=array2table(Moutput,'VariableNames',Xobj.OutputNames);

return
