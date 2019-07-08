function Xm = set(Xm,varargin)
%SET Set Parameter field contents.
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================
% EP,  03-mar-2008 
% =====================================================

warning('OpenCossan:Parameter:set:obsolete','This method is obsolete and it will be removed')

Nbin = length(varargin);
Vfields=fieldnames(Xm);

for k=1:2:Nbin
    Sfield = varargin{k};
    if any(strcmp(Sfield,Vfields))
        Xm.(Sfield) = varargin{k+1}; % DANGEROUS no control on the field kind 
    else
        OpenCossan.cossanDisp(['The field ''' Sfield ''' does not exist in ' inputname(1) ]);
    end
end
