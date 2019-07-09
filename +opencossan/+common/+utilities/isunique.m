function [Lunique] = isunique(Cinput)
%ISUNIQUE  Lout = isunique(Cinput) returns true if no items are repeated in
%the cell array Cinput   
[~,ia,ic]=unique(Cinput);
Lunique=length(ia)==length(ic);
end

