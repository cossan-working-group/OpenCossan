function parents = selection(obj, parents, offsprings)
% SELECTION

if (obj.SelectionScheme == '+')
    offsprings = [parents; offsprings];
end

[~, Vind] = sort(offsprings(:,end));
parents = offsprings(Vind(1:obj.Nmu), :);
return
