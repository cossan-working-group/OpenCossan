function [pfhat,variancepf]=...
    computeLineProbabilities(Xobj,CdistanceLimitState,CstateFlag,VdirectionalUpdate)
%COMPUTEPARTIALPROBABILITIES computes the partial probability on each
% line, given an important direction, the points coordinates in the full
% space and the respective values of the limit state boundary.

% See also: https://cossan.co.uk/wiki/index.php/AdvancedLineSampling
%
% Author: Marco de Angelis
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk
%% 

OpenCossan.cossanDisp(sprintf('*** Compute Line Probabilities'),3)


Vdistances=cell2mat(CdistanceLimitState);
VstateFlag=cell2mat(CstateFlag);

% number of processed lines
Nlines=length(Vdistances);

% Initialise cell array
CpartialProbability=cell(1,Nlines);

% Obtain conditional probabilities with standard line sampling technique
for iLine=1:Nlines
    % The pf is estimated averaging over the following number of lines
        % state flag
        stateFlag=VstateFlag(iLine);
        
        % compute conditional probabilities based on the distance from the
        % state boundary found at that iteration
        distanceLimitState=Vdistances(iLine);
        
        if stateFlag==1 || stateFlag==0
            CpartialProbability{iLine}=normcdf(-abs(distanceLimitState));
        elseif stateFlag==2
            CpartialProbability{iLine}=normcdf(abs(distanceLimitState));
        elseif stateFlag==3
            CpartialProbability{iLine}=normcdf(Inf);
        elseif stateFlag==4
            CpartialProbability{iLine}=normcdf(-Inf);
        end
end

Vprobabilities=cell2mat(CpartialProbability);


pfhat=mean(Vprobabilities);
variancepf=sum((Vprobabilities-pfhat).^2)/...
    (length(Vprobabilities)*(length(Vprobabilities)-1));
