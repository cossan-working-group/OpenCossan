function [logL] = apply(XLogL,theta)


    nSamples = size(theta,1);  
    logL = zeros(nSamples,1);

    %Here a custom likelihood defined by the user can be used
    
    Xmodel = XLogL.Xmodel;
    
    DimOut = length(Xmodel.OutputNames);
   
    Params = Xmodel.Input.Parameters;
    for n = fieldnames(Params)'
        Params.(n{1}) = repmat(Params.(n{1}).Value, nSamples, 1);
    end
    
    Tinput = struct2table(Params);
    
    tableTheta = array2table(theta);
    
    tableTheta.Properties.VariableNames = Xmodel.Input.RandomVariableNames;
    
    Tinput = [tableTheta, Tinput];
    Xout = Xmodel.apply(Tinput);
    
    output  = Xout.TableValues(:, Xmodel.OutputNames);
    output = output{:, :};
    
    D = XLogL.Data.TableValues(:, Xmodel.OutputNames);
    D = D{:, :};
    
    if ~isempty(XLogL.CustomLog)
        
        ft = XLogL.CustomLog;
        likelihood=ft(theta);
        logL = log(likelihood);
        logL(isinf(logL)) = -1e10;
        
    else
        if ~isempty(XLogL.ShapeParameters)
            epsilon_r = XLogL.ShapeParameters;
        else
            epsilon_r = std(D);
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