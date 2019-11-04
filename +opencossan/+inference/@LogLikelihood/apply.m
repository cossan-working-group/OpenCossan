function [logL] = apply(XLogL,theta)


    nSamples = size(theta,1);  
    logL = zeros(nSamples,1);

    %Here a custom likelihood defined by the user can be used
    
    Xmodel = XLogL.Xmodel;
    
    DimOut = length(Xmodel.OutputNames);
   
    DefaultVals = Xmodel.Input.getDefaultValuesTable;
    names = Xmodel.Input.ParameterNames;
    
    Nparam = Xmodel.Input.Nparameters;
    ParVals = zeros(nSamples,Nparam);
    
    for i = 1:Nparam
        Value = DefaultVals.(names{i});
        ParVals(:,i) = Value;
    end
    
    Tinput1 = cell2struct(num2cell([theta, ParVals]'),Xmodel.InputNames);
    
    Tinput = struct2table(Tinput1);
    
    Xout = Xmodel.apply(Tinput);
    output  = Xout.getValues('cnames',Xmodel.OutputNames);
    
    D = XLogL.Data.getValues('cnames',Xmodel.OutputNames);
    
    if ~isempty(XLogL.CustomLog)
        
        ft = XLogL.CustomLog;
        likelihood=ft(theta);
        logL = log(likelihood);
        logL(isinf(logL)) = -1e10;
        
    else
        if ~isempty(XLogL.ShapeParameters)
            epsilon_r = XLogL.ShapeParameters;
        else
            epsilon_r = 1e-4*ones(DimOut,1);
        end

        for iSample = 1:nSamples
            logL(iSample) = sum(( p_x_theta_pdf(D, output(iSample,:), theta(iSample,:),epsilon_r )));
            if isinf(logL(iSample))
                logL(iSample) = -1e10;
            end
        end
    end

end

function p = p_x_theta_pdf(w, w_model, theta_i, epsilon_r)
    % x       = set of observations         nobs x dim_x
    % theta_i = point in epistemic space    nsamples x dim_theta

    p = zeros(size(theta_i,1),size(w_model,2));
    %% Estimate the PDF p_x_theta_pdf(x | theta)
    % compute likelihood accordind to the GOCE paper
    % p(i) = p_x_theta_pdf(x(i,:) | theta)
    for i = 1:length(w_model)
        p(i) = (-1/2*nansum(((1-w(:,i).^2/w_model(i)^2)/epsilon_r(i)).^2,1));
    end
end