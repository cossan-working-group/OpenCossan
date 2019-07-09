function [logL] = apply(XLogL,theta)


    npar = size(theta,1);  
    logL = zeros(npar,1);

    %Here a custom likelihood defined by the user can be used
    
    
    
    if ~isempty(XLogL.CustomLog)
        
        ft = XLogL.CustomLog;
        likelihood=ft(theta);
        logL = log(likelihood);
        logL(isinf(logL)) = -1e10;
        
    elseif ~isempty(XLogL.ShapeParameters)
        
    else
        
    end
end