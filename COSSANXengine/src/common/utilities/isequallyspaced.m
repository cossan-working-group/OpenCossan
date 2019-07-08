function [Lequallyspaced, Mcoordsorted, idxsorted] = isequallyspaced(Mcoord)
% this function sort the coordinate matrix and check if the datapoint are
% equally spaced
%
% TODO: Replace uniqueTolerance with the Matlab builtin function uniquetol
%
Lequallyspaced = 0;
tol = 10^-8*max(Mcoord,[],2);
switch size(Mcoord,1)
    case 1
        [Mcoordsorted,idxsorted] = sort(Mcoord);
        if length(uniqueTolerance(diff(Mcoordsorted),tol))==1
            Lequallyspaced = 1;
        else
            Lequallyspaced = 0;
        end
    case 2
        [Mcoordsorted,idxsorted] = sortrows(Mcoord',[1 2]);
        Mcoordsorted = Mcoordsorted';
        if length(uniqueTolerance(diff(Mcoordsorted(1,:)),tol(1)))==2 && ...
                length(uniqueTolerance(diff(Mcoordsorted(2,:)),tol(2)))==2
            Lequallyspaced = 1;
        else
            Lequallyspaced = 0;
        end
    case 3
        [Mcoordsorted,idxsorted] = sortrows(Mcoord',[1 2 3]);
        Mcoordsorted = Mcoordsorted';
        if length(uniqueTolerance(diff(Mcoordsorted(1,:)),tol(1)))==2 && ...
                length(uniqueTolerance(diff(Mcoordsorted(2,:)),tol(2)))==3 && ...
                length(uniqueTolerance(diff(Mcoordsorted(3,:)),tol(3)))==2
            Lequallyspaced = 1;
        else
            Lequallyspaced = 0;
        end
end
end