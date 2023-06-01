function [beta, MPoints, VpfValues] = lineSearch(Xobj, varargin)
%LINE SEARCH METHOD
%Locate the point on the limit state for the simulated direction returning
%the distance of the point (beta), the coordinates of the evaluated
%points(MPoints) and the corresponding values of the performance function (VpfValues)

OpenCossan.validateCossanInputs(varargin{:});

acceptableError=0.01;
initialDistance=4;
Xinput=Xobj.Xmodel.Xinput;
i=3;
Vdirection = [];
pf0=[];

for k=1:2:length(varargin)
    switch (lower(varargin{k}))
        case 'vdirection'
            Vdirection = varargin{k+1};
        case 'pf0'
            pf0 = varargin{k+1};
        otherwise
            % error, unknown property specified
            error('OpenCossan:ProbabilisticModel:lineSearch',...
                ['Field name (' varargin{k} ') not allowed']);
    end
end

%Normalize the direction
Valpha=Vdirection/norm(Vdirection);
MPoints(1,:)=zeros(1,Xinput.NrandomVariables+Xinput.NdesignVariables);
Vdistances(1)=0;

if isempty(Vdirection)
    error('openCOSSAN:reliability:ProbabilisticModel:lineSearch',...
        'Direction not defined');
end

Xsample = Samples ('Xinput',Xinput,'MsamplesStandardNormalSpace',MPoints(1,:));
if isempty(pf0)
    % Compute performance function in point0
    Xout_pf1 = Xobj.apply(Xsample);
    VpfValues(1) = Xout_pf1.getValues('Sname',Xobj.XperformanceFunction.Soutputname);
else
    VpfValues(1)=pf0;
end

%Generate the first point at the InitialDistance
MPoints(2,:)=initialDistance*Valpha;
Xsample.MsamplesStandardNormalSpace = MPoints(2,:);
Xout_pf2 = Xobj.apply(Xsample);
VpfValues(2)=Xout_pf2.getValues('Sname',Xobj.XperformanceFunction.Soutputname);
Vdistances(2)=initialDistance;
%Does the direction simulated intersect the perfomance function?
Vdistances(3)=-VpfValues(1)*initialDistance/(VpfValues(2)-VpfValues(1));

if (Vdistances(3)>=0)
    MPoints(3,:)=Vdistances(3)*Valpha; %intersection point
    %compute the pf in the intersection point
    Xsample.MsamplesStandardNormalSpace = MPoints(3,:);
    Xout_pf3 = Xobj.apply(Xsample);
    VpfValues(3)= Xout_pf3.getValues('Sname',Xobj.XperformanceFunction.Soutputname);
    
    while min(abs(VpfValues)) > acceptableError
        
        p=polyfit([Vdistances(1), Vdistances(i-1), Vdistances(i)],...
            [VpfValues(1), VpfValues(i-1), VpfValues(i)],2);
        a=roots(p);
        if ~any(isreal(a))
            Vdistances(i)=inf;
            break
        end
        i=i+1;
        Vdistances(i)=min(a(a>0));
        MPoints(i,:)=Vdistances(i)*Valpha;
        Xsample.MsamplesStandardNormalSpace = MPoints(i,:);
        Xout_pf =Xobj.apply(Xsample);
        VpfValues(i)=Xout_pf.getValues('Sname',Xobj.XperformanceFunction.Soutputname);
    end
    beta=Vdistances(i);
else
    beta=inf;
end
end
