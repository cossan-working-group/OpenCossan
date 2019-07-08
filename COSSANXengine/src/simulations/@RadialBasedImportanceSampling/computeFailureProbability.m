function Xpf = computeFailureProbability(Xobj, Xpm)
%Compute the FailureProbability
%This method return the FailureProbability value associated to the
%
% See also:
% https://cossan.co.uk/wiki/index.php/computeFailureProbability@Simulation
%
% Author: Silvia Tolo
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

warning('This function should call the method checkInput')
%% Initial Values
Xinput = Xpm.Xmodel.Xinput;
Ndim = Xinput.NrandomVariables+Xinput.NdesignVariables; %Dimension of the space
Npoints=1;%number of (exact+approximate) evaluations of the performance function


%% Check input
% Check initial directions
if isempty(Xobj.MVdirection)
    Xobj.MVdirection = randn(Ndim); %Matrix of the initial directions
end
assert(size(Xobj.MVdirection,2)==Ndim,'OpenCossan:RadialBasedImportanceSampling:pf',...
    ['The number of columns in the user defined direction (' num2str(size(Xobj.MVdirection,2)) ...
    ') is not compliant with the number of inputs (' num2str(Ndim) ')']);

%check the model

%check performance function

%% Compute 2*Ndim+1 initial exact points
% Apply lineSearch method to the initial directions
for i=1:1:(size(Xobj.MVdirection,1))
    Vdirection=Xobj.MVdirection(i,:);
    % Evaluate the value of performance function in the origin
    if i==1
        [beta, MPoints, VpfValues] = Xpm.lineSearch('Vdirection',Xobj.MVdirection(i,:));
        pf0 = VpfValues(1);
        Mcoord(1,:)=MPoints(1,:); % save the value in the origin only the first time
    else
        [beta, MPoints, VpfValues] = Xpm.lineSearch('Vdirection',Xobj.MVdirection(i,:),'pf0',pf0);
    end
    % Store the results
    if beta>7.5
        Vdistances(i)=inf;
    else
        Vdistances(i)=beta; %Vector of minimum distances between the origin and the limit state function on each direction
    end
    Mcoord((Npoints+1):(Npoints+size(MPoints,1))-1,:)=MPoints(2:end,:); %Store the points evaluated
    VperformanceFunction((Npoints+1):(Npoints+size(MPoints,1))-1,1)=VpfValues(2:end);  %Vector of performance function values corresponding to the points stored in Mpoints
    Npoints=size(Mcoord,1); %number of points stored in Mcoord
end
% Ensure the availability of 2*Ndim+1 points for the construction of RS
while ~Npoints==(2*Ndim+1)
    Ndirections=size(Xobj.MVdirection,1); %number of directions evaluated with exact lineSearch
    Xobj.MVdirection(Ndirections+1,:)=randn(1,Ndim);
    [beta, MPoints, VpfValues] = Xpm.lineSearch('vdirection',Xobj.MVdirection(Npoints+1,:));
    z=size(MPoints,1); %number of points evaluated by lineSearch
    Mcoord((Npoints+1):(Npoints+z),:)=Mpoints; %Store the points evaluated
    VperformanceFunction((Npoints+1):(Npoints+z))=VpfValues;
    Vdistances(Npoints+1)=beta;
    %upload Npoints
    Npoints=size(Mcoord,1);
end


%% Exact/Approximate simulations
% In this phase "exact simulations"="total simulations"
% Store exact values needed for the RS
ExactVperformanceFunction=VperformanceFunction;
ExactDistances=Vdistances;
ExactMcoord=Mcoord;
% Starting values
Npoints=size(Mcoord,1);
Ndirections=size(Xobj.MVdirection,1);
betamin=min(Vdistances);
% First evaluation of failure probability
Pdirection= 1-chi2cdf(Vdistances.^2,Ndim);
pf_hat=(sum(Pdirection,Ndim))/length(Pdirection);
variance=sum((Pdirection-pf_hat*ones(1,length(Pdirection))).^2)/(length(Pdirection)*(length(Pdirection)-1));
COV=sqrt((1-pf_hat)/(Npoints*pf_hat));
RelativeError=norminv(0.975,0,1)*COV; %For a confidence level of 0.95
% First version of RS
SRStype = 'purequadratic';
McoeffRS=x2fx(ExactMcoord,SRStype)\ExactVperformanceFunction;

%% Check Convergence
while (RelativeError>Xobj.acceptableError || isnan(RelativeError))
    %Generate and store new direction
    Xobj.MVdirection(end+1,:)=randn(1,Ndim);
    Valpha = Xobj.MVdirection(end,:)/norm(Xobj.MVdirection(end,:));
    fx_dir = x2fx([0*Valpha;Valpha; Valpha*2],SRStype)*McoeffRS;
    %Find the intersection
    p=polyfit([0; 1; 2],fx_dir,2);
    intersection = roots(p);
    intersection(intersection<0)=[];
    Npoints=size(Mcoord,1);
    if isempty(intersection) || ~isreal(intersection)
        beta_rs = inf;
    else
        beta_rs=min(intersection); %distance of the intersection
    end
    if beta_rs<(betamin+Xobj.DeltaBeta)
        % Exact lineSearch
        [beta, MPoints, VpfValues] = Xpm.lineSearch('Vdirection',Xobj.MVdirection(end,:),'pf0',pf0);
        % Store results as exact
        ExactDistances(end+1)=beta;
        ExactNpoints=size(ExactMcoord,1);
        ExactMcoord((ExactNpoints+1):(ExactNpoints+size(MPoints,1))-1,:)=MPoints(2:end,:);
        ExactVperformanceFunction((ExactNpoints+1):(ExactNpoints)+(size(MPoints,1)-1))= VpfValues(1,2:end);
        % Store results as total
        Mcoord((Npoints+1):(Npoints+size(MPoints,1))-1,:)=MPoints(2:end,:);
        VperformanceFunction((Npoints+1):(Npoints+size(MPoints,1))-1,1)=VpfValues(2:end);
        Vdistances(end+1)=beta;
        % Upload betamin if necessary and RS
        if Vdistances(end)<betamin
            %if you start updating the RS, it changesfrom putrequadratic to
            %interaction
            SRStype = 'interaction';

            betamin=Vdistances(end);
            McoeffRS=x2fx(ExactMcoord,SRStype)\ExactVperformanceFunction;
            % Recompute approximate results in light of new RS information
            for idir = 1:size(Xobj.MVdirection,1)
                % find the intersection of RS with every direction
                Valpha = Xobj.MVdirection(idir,:)/norm(Xobj.MVdirection(idir,:));
                fx_dir = x2fx([0*Valpha;Valpha; Valpha*2],SRStype)*McoeffRS;
                p=polyfit([0; 1; 2],fx_dir,2);
                intersection = roots(p);
                intersection(intersection<0)=[];
                if isempty(intersection) || ~isreal(intersection) || min(intersection)>7.5
                    Vdistances(idir) = inf;
                else
                    Vdistances(idir) = min(intersection); %distance of the intersection
                end
            end
        end
    else
        if isempty(intersection) || ~isreal(intersection) || min(intersection)>7.5
            Vdistances(end+1) = inf;
        else
            Vdistances(end+1) = min(intersection); %distance of the intersection
        end
        Mcoord(end+1,:)=beta_rs*Xobj.MVdirection(end,:);
        VperformanceFunction(end+1)=x2fx(Mcoord(end,:),SRStype)*McoeffRS;
    end
    %% Compute the results
    Pdirection= 1-chi2cdf(Vdistances(~isinf(Vdistances)).^2,Ndim);
    pf_hat=(sum(Pdirection))/(length(Pdirection));
    variance_pf=sum((Pdirection-pf_hat*ones(size(Pdirection))).^2)/((length(Pdirection))*(length(Pdirection)-1));
    COV=sqrt(variance_pf)/pf_hat;
%     COV=sqrt((1-pf_hat)/(size(Mcoord,1)*pf_hat));
    RelativeError=norminv(0.975,0,1)*COV; %For a confidence level of 0.95
    scatter(ExactMcoord(:,1),ExactMcoord(:,2),'.');drawnow
end
Xpf=FailureProbability('CXmembers',{Xpm},'Smethod','RadialBasedImportanceSampling', ...
    'pf',pf_hat,'variancepf',variance_pf,'Nsamples',size(ExactMcoord,1));%,'RelativeError',RelativeError);

% Restore Global Random Stream
restoreRandomStream(Xobj);

end
