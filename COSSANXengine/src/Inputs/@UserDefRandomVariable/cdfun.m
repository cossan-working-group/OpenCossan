function Xobj = cdfun(Xobj)
%CDFUN compute missing parameters (if is possible) of the userdefined
%                       distribution


if ~isempty(Xobj.Xfunction) && ~isempty(Xobj.Vdata(1))
    
    if isempty(Xobj.Vtails)
        Xobj.Vtails = [.1 .9];
    end
    
    fun = @(x)buildcdf1(x,Xobj.Xfunction);
    VdataCensored = censoring(Xobj,fun);
    %build the distribution using the function and the points provided by the
    %user
    try
        Xobj.empirical_distribution =  paretotails(VdataCensored,min([Xobj.Vtails]),max([Xobj.Vtails]),fun);
    catch ME
        error('openCOSSAN:UserDefRandomVariable:cdfun',ME.message);
    end
    
elseif size(Xobj.Vdata,2) ==2        
    %the userdefrv is created with an array containing values of the cdf
    if min(Xobj.Vdata(:,2))<0 ||max(Xobj.Vdata(:,2))>1
        error('openCOSSAN:UserDefRandomVariable:cdfun','the value of the cdf must be in the range [0 1]');
    end
    
    if isempty(Xobj.Vtails)
        Xobj.Vtails(1) = min(0.1, min(Xobj.Vdata(:,2)));
        Xobj.Vtails(2)= max(0.9, max(Xobj.Vdata(:,2)));
    end
    
    fun = @(x)buildcdf2(x,Xobj.Vdata);
    VdataCensored = censoring(Xobj,fun);
    %build the distribution using the function and the points provided by the
    %user
    try
        Xobj.empirical_distribution =  paretotails(linspace(min(VdataCensored(:,1)),max(VdataCensored(:,1)),101),min([Xobj.Vtails]),max([Xobj.Vtails]),fun);
    catch ME
        error('openCOSSAN:UserDefRandomVariable:cdfun',ME.message);
    end
    
else
    error('openCOSSAN:UserDefRandomVariable:cdfun', ...
        'userdefined can be defined only via a cfd function and an array containing the values of the cdf to interpolate)');
end
%generate sample to approximate the characteristics of the distribution
Vu=random(Xobj.empirical_distribution,Xobj.NsampleFit,1);
Xobj.mean = mean(Vu);
Xobj.std  = std(Vu);
Xobj.lowerBound = min(Xobj.Vdata(:,1));
Xobj.upperBound = max(Xobj.Vdata(:,1));

end


function [p,xi]= buildcdf1(x1,fun)
% x1: evaluation points
% fun: CossanX Function

xi=sort(x1);
% Get Function name
Cname = fun.Ctoken{1}(1);
Xpar=Parameter;
Xpar.value=x1;
Xin=Input('CXmembers',{Xpar},'CSmembers',Cname);
p=evaluate(fun,Xin)';

end


function [p,xi]= buildcdf2(x1,Vdata)

xi=sort(x1);
p=interp1(Vdata(:,1),Vdata(:,2),xi);

end

function VdataCensored = censoring(Xobj,fun)
    Vcdf = fun(Xobj.Vdata(:,1));
    idxCensored=find(Vcdf==1,2);
    VdataCensored = Xobj.Vdata;
    if ~isempty(idxCensored) && length(idxCensored)>1
        VdataCensored(idxCensored(2):end,:) = [];
    end
end