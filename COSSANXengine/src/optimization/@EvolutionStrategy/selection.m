function [Mparents] = selection(Xobj,Mparents,Moffspring)
% SELECTION: Private method for EvolutionStrategy

if (Xobj.Sselection=='+'),
    Moffspring  = [Mparents;Moffspring];
end

[~,Vind] = sort(Moffspring(:,end));
Mparents    = Moffspring(Vind(1:Xobj.Nmu),:);

return
