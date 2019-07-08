function [ Xdv ] = randomVariable2designVariable( Xrv )
% RANDOMVARIABLE2DESIGNVARIABLE this method transforms a RandomVariable into
% a DesignVariable

Xdv = DesignVariable();

if ~isinf(Xrv.mean) && ~isnan(Xrv.mean)
    Xdv.value = Xrv.mean;
else
    error('openCOSSAN:RandomVariable:randomVariable2designVariable',...
                     'The mean of the distribution is not defined')
end


if ~isinf(Xrv.lowerBound) && ~isnan(Xrv.lowerBound)
    Xdv.lowerBound = Xrv.lowerBound;
end


if ~isinf(Xrv.upperBound) && ~isnan(Xrv.upperBound)
    Xdv.upperBound = Xrv.upperBound;
end

end

