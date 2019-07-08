function varargout=plotMarkovChains(Xobj,varargin)
%PLOT method plots the samples generate for each level 
%
% See also:
% https://cossan.co.uk/wiki/index.php/plot@SubsetOutput
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

Stitle='Subset simulation output';
SyLabel=Xobj.SperformanceFunctionName;
Smarker='-';
Svisible='on';
NplotLevels=length(Xobj.VsubsetFailureProbability);

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sfigurename'
            Sfigurename=varargin{k+1};
        case 'stitle'
            Stitle=varargin{k+1};
        case 'nmaxlevels'
            NplotLevels=varargin{k+1};
        case 'smarker'
            Smarker=varargin{k+1};
        case 'Cnames'
            Cnames=varargin{k+1};
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        otherwise
            error('openCOSSAN:SubsetOutput:plot:wrongArguments',...
                  'Field name %s is not valid',varargin{k});
    end
end

%% Check data
Vg=Xobj.getValues('Sname',Xobj.SperformanceFunctionName);

%% Initialize figure
fh=figure('Visible',Svisible);
varargout{1}=fh;
hold(gca(fh),'on');

if exist('Cnames','var')
    Mdata=Xobj.getValues('Cnames',Cnames);
end
  

scatter(ones(Xobj.NinitialSamples,1),Vg(1:Xobj.NinitialSamples))
hold

scatter(ilevel*ones(Xobj.NinitialSamples,1),Vg(reshape(Xobj.MchainIndices(:,:,1),1,[])),'r')

for n=1:NplotLevels
    
                scatter(Vg,'ob'),hold on,        

                %figure
                scatter(MU,Xobj.VsubsetPerformance,'ob'),hold on,                
                
                % Merge SimulationData objectd
                % rejected values are saved nevertheless
                XbatchSimOut=XbatchSimOut.merge(Xout_tmp);
                
                % Get the new values of the performance function
                Vg_temp=Xout_tmp.getValues('Sname',Xtarget.XperformanceFunction.Soutputname);
                
                scatter(MprososedSamples,Vg_temp,'xr'),
                % Identify the samples that have to be rejected. The
                % rejecte points corresponds to the samples whose
                % performance function value is below the subset value (the
                % removed states of the chain are set equal to the previous
                % ones)
                Vaccepted=find((Vg_temp <= VgFl(ilevel))==1);
                
                scatter(MprososedSamples(Vaccepted),Vg_temp(Vaccepted),'.g')
                % Update the vector of the performance function
                Vg_subset(Vaccepted)= Vg_temp(Vaccepted);                
                MU(Vaccepted)=MprososedSamples(Vaccepted);                
                % Store the number of rejected samples
                Nrejection=Ninitialsamples-length(Vaccepted);        
    
end

% Custumize figure
box(gca(fh),'on');
grid(gca(fh),'on');

ylabel(gca(fh),SyLabel,'FontSize',16)
title(gca(fh),Stitle);

set(gca(fh),'FontSize',16);

if exist('Sfigurename','var')
    saveas(fh,Sfigurename,'eps')
end

varargout{1}=fh;
end



