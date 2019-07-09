function Voutput=radialExponentialPDF(Minput,par1)

% Minput(:,1)     contains samples of the radius
% Minput(:,2:end) contains samples of the angles in the spherical reference
% par1:           mean of the exponential distribution 


[~,Nvars]=size(Minput); 

if Nvars==1
    % pdf(x)=1/2*par*exp(-|x|/par)
    Voutput=(1/2)*(1/par1)*exp(-(1/par1).*abs(Minput(:,1)));
else
    % pdf(x)=1/(2pi)*(1/pi)^(n-2)*(1/par)*exp(-x/par)
    Voutput=(1/2/pi)*(1/pi)^(Nvars-2)*(1/par1)*exp(-(1/par1).*Minput(:,1));
end