function [Lcheck varargout] = check(Vmembers)
%CHECK 
% This is a private function for the rvset class
% Check if the rv are present in the workspace


%% 1. Processing Inputs

Tv=evalin('base', 'whos'); % read the content of the basic workspace

Crv=cell(length(Vmembers),1);
ifound=0;

for ick=1:length(Tv)
    if strcmp(Tv(ick).class,'RandomVariable')
        Nrv=sum((strcmp(Vmembers,Tv(ick).name)));
        if Nrv>0
            for irv=1:Nrv
                Crv{ifound+Nrv}=Tv(ick).name;
            end
            ifound=ifound+Nrv;
        end
    end
end

if ifound==length(Vmembers)
    Lcheck=true;
else
    Lcheck=false;
end

varargout{1}=Crv;