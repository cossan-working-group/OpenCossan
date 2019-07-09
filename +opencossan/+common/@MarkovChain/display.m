function display(Xmkv)
%DISPLAY   Displays MarkovChain object information
%  DISPLAY(XMKV)  


opencossan.OpenCossan.cossanDisp('****************************************************************** ');
opencossan.OpenCossan.cossanDisp('*     MarkovChain Object                                         * ')
opencossan.OpenCossan.cossanDisp('****************************************************************** ');

opencossan.OpenCossan.cossanDisp('RandomVariableSet of the base:')
Xmkv.Base

opencossan.OpenCossan.cossanDisp('RandomVariableSet of the offsring:')
Xmkv.OffSprings

opencossan.OpenCossan.cossanDisp('Initial samples:')
if ~isempty(Xmkv.Samples)
Xmkv.Samples(1)
end

opencossan.OpenCossan.cossanDisp('-----------------------------------------------------------')
if ~isempty(Xmkv.Samples)
opencossan.OpenCossan.cossanDisp([ num2str(Xmkv.Samples(1).Nsamples) ' Markov Chains defined'])
end
opencossan.OpenCossan.cossanDisp([ 'Length of the chains: ' num2str(Xmkv.lengthChains) ...
    ' (total points ' num2str(length(Xmkv.Samples)) ') ' ])
opencossan.OpenCossan.cossanDisp([ 'Burnin: ' num2str(Xmkv.burnin) ' Thin: ' num2str(Xmkv.thin) ])
opencossan.OpenCossan.cossanDisp('-----------------------------------------------------------')
