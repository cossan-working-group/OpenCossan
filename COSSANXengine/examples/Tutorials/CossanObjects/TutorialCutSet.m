%% Tutorial for the CutSet object
% The cutset object is an output object that contains the results of the
% analysis. It is create automatically invoking the method
% pf@Systemreliability or DesignPoint@SystemReliability.
% 
% Please refer to the Tutorial of SystemReliability for more details.
%
%
% See Also:  http://cossan.co.uk/wiki/index.php/@Constraint
%
% $Copyright~1993-2019,~COSSAN~Working~Group$
% $Author: Edoardo~Patelli$ 

%% The CutSet object can be constructed manually by means the constructor
% CutSet

% in this case the CutSet contains only the indices of the component
% forming the cut set
Xcs=CutSet('VcutSetIndex',[1 4 5]);
display(Xcs)

% The cutset is much more informative when create by the SystemReliability
% object.

%% Please see the Tutorial of SystemReliability
load Xobject
Xcs=CutSet('VcutSetIndex',[1 2],'XFaultTree',Xft,'XDesignPoint',Xdp);
display(Xcs)

