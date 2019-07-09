function disp(Xobj)
%DISPLAY   Displays the information related to the stochastic process
%  DISPLAY(StochasticProcess) prints the name, distribution type, mean
%  value and autocorrelation of the specified stochastic process


for j=1:length(Xobj)
    
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp([' ' class(Xobj(j)) ' Object  -  Description: ' Xobj(j).Sdescription],1);
    OpenCossan.cossanDisp('===================================================================',3);
    
    if strcmp(Xobj(j).Sdistribution,'null')
        return
    end
    
    OpenCossan.cossanDisp(['* Distribution: ' Xobj(j).Sdistribution],3);
    
    if Xobj(j).Lhomogeneous
         OpenCossan.cossanDisp('* Homogeneous StochasticProcess',3);
    else
        OpenCossan.cossanDisp('* Nonhomogeneous StochasticProcess',3);
    end
    
    
    OpenCossan.cossanDisp(sprintf('* %i-D dimensional StochasticProcess ',size(Xobj(j).Mcoord,1)),3);
    
    if ~isempty(Xobj(j).VcovarianceEigenvalues)
        OpenCossan.cossanDisp(sprintf('* %u computed K-L terms (Max: %e; Min: %e)',...
            length(Xobj(j).VcovarianceEigenvalues),max(Xobj(j).VcovarianceEigenvalues),...
            min(Xobj(j).VcovarianceEigenvalues)),3);
    else
        OpenCossan.cossanDisp('* No computed K-L terms ',3);
    end
end



return;
