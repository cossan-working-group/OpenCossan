function [Lequallyspaced, Mcoordsorted, idxsorted] = isequallyspaced(Mcoord,RelativeTolerance)
% this function sort the coordinate matrix and check if the datapoint are
% equally spaced

if nargin==1
    Vtol = eps(max(Mcoord,[],2));
else
    Vtol = RelativeTolerance*(max(Mcoord,[],2));
end

Lequallyspaced = 0;

switch size(Mcoord,1)
    case 1
        [Mcoordsorted,idxsorted] = sort(Mcoord);
        if length(uniquetol(diff(Mcoordsorted),Vtol))==1
            Lequallyspaced = 1;
        end
    case 2
        [Mcoordsorted,idxsorted] = sortrows(Mcoord',[1 2]);
        Mcoordsorted = Mcoordsorted';
        if length(uniquetol(diff(Mcoordsorted(1,:)),Vtol(1)))==2 && ...
                length(uniquetol(diff(Mcoordsorted(2,:)),Vtol(2)))==2
            Lequallyspaced = 1;
        end
    case 3
        [Mcoordsorted,idxsorted] = sortrows(Mcoord',[1 2 3]);
        Mcoordsorted = Mcoordsorted';
        if length(uniquetol(diff(Mcoordsorted(1,:)),Vtol(1)))==2 && ...
                length(uniquetol(diff(Mcoordsorted(2,:)),Vtol(2)))==3 && ...
                length(uniquetol(diff(Mcoordsorted(3,:)),Vtol(3)))==2
            Lequallyspaced = 1;
        end
end
end
