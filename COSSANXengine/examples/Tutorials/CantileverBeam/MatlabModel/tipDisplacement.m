%% tipDisplacement script
%
% This script computes the tips displacement (w) of the cantilever beam
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 


for n=1:length(Tinput)
    Toutput(n).w=(Tinput(n).rho*9.81*Tinput(n).b*Tinput(n).h*Tinput(n).L^4)/(8*Tinput(n).E*Tinput(n).I) + ...
(Tinput(n).P*Tinput(n).L^3)/(3*Tinput(n).E*Tinput(n).I); 
end
