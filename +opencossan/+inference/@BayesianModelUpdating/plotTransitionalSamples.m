function out = plotTransitionalSamples(~, SimData, names, indicies)
    %%%
    %   This method plots the transitional samples, from a tmcmc output
    %
    %   SimData: simulation data object output from applyTMCMC.m 
    %
    %   names: array of strings of the variables you wish to plot. This input
    %   is manditory
    %
    %   indicies: a vector of integers (i.e [0,2,4]) defining which 
    %   levels of samples you wish to plot. 0 being the prior. The 
    %   posterior will always be plot. If indicies is empty all levels will
    %   be plot
    %
    %   
    %%%
    
    numVars = length(names);
    
    TableValues = SimData.TableValues;
    
    names2 = TableValues.Properties.VariableNames;
    kk = cellfun(@(n) startsWith(n, names(1)), names2);
    numIterations = sum(kk)-1;
    
    if ~exist('indicies','var')
        indicies = 0:1:numIterations-1;
    end
    
    numIndicies = length(indicies);
    
    CatNames = string();
    for i = indicies
        for j = names
            CatNames = [CatNames; strcat(j,'_',num2str(i))];
        end
    end
    
    CatNames = [CatNames;names'];
    
    CatNames(1) = [];
    
    
    pdata = [];
    datas1 = [];
    for n = 1:length(CatNames)
        datas1 = [datas1,TableValues.(CatNames(n))];
    end
    
    NumSamples = size(datas1,1);
    pdata=[];
    for i = 1:numVars
       pdata = [pdata,reshape(datas1(:,i:numVars:(numIndicies+1)*numVars),[NumSamples*(numIndicies+1),1])];
    end
    
    group = [];
    for i = indicies
        if i == 0
            title = "prior";
        else
            title = strcat("Bj = ", num2str(i));
        end
        group = [group; repmat(title,NumSamples,1)];
    end
    
    group = [group; repmat("posterior",NumSamples,1)];
    
    colors = lines(numIndicies+1);
    figure;

    [k] = gplotmatrix(pdata,[],group,colors,[],repmat(8,numIndicies+1),[],'grpbars',names);
    
    for i = 1:numVars
        h = k(i,i,:);
        for j = 1:length(h)
            h(j).FaceAlpha = 0.4;
        end
    end
         
end