function display(Xmkv)
%DISPLAY   Displays MarkovChain object information
%  DISPLAY(XMKV)  


OpenCossan.cossanDisp('****************************************************************** ');
OpenCossan.cossanDisp('*     MarkovChain Object                                         * ')
OpenCossan.cossanDisp('****************************************************************** ');

OpenCossan.cossanDisp('RandomVariableSet of the base:')
Xmkv.Xbase

OpenCossan.cossanDisp('RandomVariableSet of the offsring:')
Xmkv.XoffSprings

OpenCossan.cossanDisp('Initial samples:')
if ~isempty(Xmkv.Xsamples)
Xmkv.Xsamples(1)
end

OpenCossan.cossanDisp('-----------------------------------------------------------')
if ~isempty(Xmkv.Xsamples)
OpenCossan.cossanDisp([ num2str(Xmkv.Xsamples(1).Nsamples) ' Markov Chains defined'])
end
OpenCossan.cossanDisp([ 'Length of the chains: ' num2str(Xmkv.lengthChains) ...
    ' (total points ' num2str(length(Xmkv.Xsamples)) ') ' ])
OpenCossan.cossanDisp([ 'Burnin: ' num2str(Xmkv.burnin) ' Thin: ' num2str(Xmkv.thin) ])
OpenCossan.cossanDisp('-----------------------------------------------------------')
