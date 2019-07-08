function Xobj = computeProposalDistribution(Xobj,Xtarget)
%COMPUTEPROPOSALDISTRIBUTION method.
% This method is used to compute the proposal distribution for the
% ImportaceSampling object.
% The proposal distribution is computed adopting gaussian distributions
% centred on the design point. Hence, the design point of the target object
% is computed.
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/computeProposalDistribution@ImportanceSampling
%
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

if Xobj.Lcomputedesignpoint
    % The Design Point can be computed automatically only on the
    % Probabilistic Model
    
    assert(isa(Xtarget,'ProbabilisticModel'), ...
        'openCOSSAN:InportanceSampling',...
        strcat('The DesignPoint can be computed automatically only on ProbabilisticModel object. \n',...
        'Provided target object of type (%s) not allowed'),class(Xtarget));
    
    Xdp=Xtarget.designPointIdentification;
    
else
    assert(isa(Xtarget,'DesignPoint'), ...
        'openCOSSAN:InportanceSampling',...
        'A DesignPoint object is to define the proposal distribution!\n Provided object class: %s', ...
        class(Xtarget));
    Xdp=Xtarget;
end

%% Define Proposal density from the design
%% point
% Only Gaussian Random Variables are used to
% define the proposal distribution from the design
% point.
Vdp=Xdp.VDesignPointPhysical;
[~, Vstd] = Xdp.Xinput.getMoments;
Crvnames=Xdp.Xinput.CnamesRandomVariable;
for irv=1:length(Vdp)
    XrvDP{irv}=RandomVariable('Sdistribution','normal', ...
        'mean',Vdp(irv),'std',Vstd(irv)); %#ok<AGROW>
    CrvnamesUD{irv}=[Crvnames{irv} '_dp'];   %#ok<AGROW>
end
Xobj.XrvsetUD={RandomVariableSet('CXrv',XrvDP,'Cmembers',CrvnamesUD)};
Xobj.Cmapping=[CrvnamesUD' Crvnames'];


