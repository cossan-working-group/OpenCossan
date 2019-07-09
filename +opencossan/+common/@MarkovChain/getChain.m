function MX = getChain(Xobj,varargin)
%getChain This method export the chain from the MarkovChain object
%   The method returns a matrix with the samples ordered according to the
%   chains. MX = [1:Nrv,1:end chain 1] [1:Nrv,1:end chain 2] ....
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getChain@MarkovChain
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================      
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli Pierre Beaurepaire

opencossan.OpenCossan.validateCossanInputs(varargin{:})
Vchain=1:size(Xobj.Minitial,1);
Lsns=false;
%% Process inputs
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'vchain'}
                Vchain=varargin{k+1};
            case {'lstandardnormalspace','lsns'}
                Lsns=varargin{k+1};
            otherwise
                error('openCOSSAN:MarkovChain:getChain',...
                    'Input parameter not allowed (please use the command: doc MarkovChain/getChain)')
        end
    end

MX=zeros(length(Vchain)*Xobj.lengthChains,Xobj.Xbase.Nrv);

% indices for the chains
Vposition=(0:length(Vchain)-1)*(Xobj.lengthChains)+1;

iring=0;
for istep=Xobj.burnin+1:Xobj.thin:length(Xobj.Xsamples)
    iring=iring+1;
    if Lsns
        MX(Vposition+(iring-1),:)=Xobj.Xsamples(istep).MsamplesStandardNormalSpace(Vchain,:);
    else
        MX(Vposition+(iring-1),:)=Xobj.Xsamples(istep).MsamplesPhysicalSpace(Vchain,:);
    end
end

end
