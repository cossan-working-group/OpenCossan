function [Xout varargout ]= apply(Xobj, Pinput)
%APPLY method. This method estimates the fatigue life using the object
% passed as the argument


switch class(Pinput)
    case 'struct'
        Tstruct=Pinput;
        Nsamples = length(Pinput); 
    case 'Input'
        Tstruct = Pinput.getStructure;
        Nsamples = Pinput.Xsamples.Nsamples;
    case 'Samples'
        Tstruct=Pinput.Tsamples;
        Nsamples = Pinput.Nsamples;
    otherwise
        error('openCOSSAN:FatigueFracture:apply',...
            ['Cannot execute apply method. Input file of class  ' class(Pinput) ' not allowed.'])
end



for iSample  =1:Nsamples
    
    
    %% integration of Paris-Erdogan equation
    
    %initial crack length
    a0 = zeros(length(Xobj.Ccrack),1);
    for iCrack = 1:length(Xobj.Ccrack)
        a0(iCrack,1) = getfield(Tstruct(iSample),Xobj.Ccrack{iCrack});
    end
    
    % Paris-Erdogan law
    PEL = @(n,a)pariserdogan(n,a,Tstruct(iSample),Xobj);
    %Paris-Erdogan law as a function of the maximum and minimum stresses, the crack size and the number of load cycles (n)
    
    
    
    %options of the differential equation integration
    options = odeset('events',@(n,a)evntfcn(a,n,Tstruct(iSample),Xobj),'RelTol',.001,'AbsTol',1e-6);
    
    try
        OpenCossan.cossanDisp('[FatigueFracture:apply] Performing numerical integration',4)
    switch Xobj.solver
        case {'ode113'}
            %integration
            [N,a] = ode113(PEL,[0 Inf],a0,options);
            %N is an arrax containing the number of cycles
            %a is an array containing the crack lengths
        case {'ode45'}
            %integration
            [N,a] = ode45(PEL,[0 Inf],a0,options);
            %N is an arrax containing the number of cycles
            %a is an array containing the crack lengths
            
    end
    catch ME
        error('openCOSSAN:FatigueFracture:apply',...
            [' The numerical integration was not performed ' ...
            ' Please check your scripts \n' ME.message])
        
    end
    
    Xds = Dataseries('Mcoord',N*ones(size(a(1,:))),'Mdata',a,'Sindexname','Time','Sindexunit','Cycle');
    
    if iSample==1
        Xffo = FatigueFractureOutput('Cnames',Xobj.Ccrack,'Xdataseries',Xds);
        Tout=struct(Xobj.Coutputnames{1},num2cell(zeros(length(Nsamples),1)));
        Tout(iSample).(Xobj.Coutputnames{1}) = N(end);
    else
        Xffo =Xffo.addSimulation(Xds);
        Tout(iSample).(Xobj.Coutputnames{1}) = N(end);
    end

end
    Xout = SimulationData('Tvalues',Tout);
    if nargout == 2
        varargout = {Xffo};
    end


end %end apply


%crack growth according to paris erdogan equation
function dadn = pariserdogan(n,a,Tstruct,Xobj)

%actualisation of the crack lengths in the dummy structure
for i = 1:length(Xobj.Ccrack)
    Tstruct = setfield(Tstruct,Xobj.Ccrack{i},real(a(i)));
end

%estimation of stress intensity factor(s)
if ~isempty(Xobj.Xsolver)
    tempvalue = Xobj.Xsolver.apply(Tstruct);
else
    %retrieves the names of the outputs
    CsolverOutName = {};
    Vnout = zeros(length(Xobj.CXsolver),1);
    for i=1:length(Xobj.CXsolver)
        
        
        
            CsolverOutName = [CsolverOutName Xobj.CXsolver{i}.Coutputnames]; %#ok<AGROW>
            if isa(CXsolver{i}.Coutputnames,'cell')
                Vnout(i) = length(Xobj.CXsolver{i}.Coutputnames);
            else
                Vnout(i) = 1;
            end

        
        
    end
    %execution of all the solvers
    Mout = zeros(1,length(CsolverOutName));
    Nindex  =1;
    for i=1:length(Xobj.CXsolver)
        tempvalue = Xobj.CXsolver{i}.apply(Tstruct);
        
        Mout(Nindex:Nindex+Vnout(i)-1) = tempvalue.getValues('Cnames',{Xobj.CXsolver{i}.Coutputnames});
        
        
        Nindex = Nindex+Vnout(i);
    end
    tempvalue = SimulationData('Cnames',CsolverOutName,'Mvalues',Mout);
    tempvalue2 =SimulationData('Tvalues',Tstruct);
    tempvalue = merge(tempvalue,tempvalue2);
end
dadn=real(Xobj.XcrackGrowth.evaluate(tempvalue.Tvalues));

end



% Auxiliary function to integrate differential equation
%is equal to 0 whe Kic is reached
function [value,isterminal,direction] = evntfcn(a, ~,Tstructure,Xobj)

%% updates the dummy structure with actual crack lengths
for i = 1:length(Xobj.Ccrack)
    Tstructure = setfield(Tstructure,Xobj.Ccrack{i},a(i));
end

if ~isempty(Xobj.Xsolver)
    tempvalue = Xobj.Xsolver.apply(Tstructure);
else
    %retrieves the names of the outputs
    CsolverOutName = {};
    Vnout = zeros(length(Xobj.CXsolver),1);
    for i=1:length(Xobj.CXsolver)
        
        
        CsolverOutName = [CsolverOutName Xobj.CXsolver{i}.Coutputnames]; %#ok<AGROW>
        if isa(CXsolver{i}.Coutputnames,'cell')
            Vnout(i) = length(Xobj.CXsolver{i}.Coutputnames);
        else
            Vnout(i) = 1;
        end
        
        
        
    end
    %execution of all the solvers
    Mout = zeros(1,length(CsolverOutName));
    Nindex  =1;
    for i=1:length(Xobj.CXsolver)
        tempvalue = Xobj.CXsolver{i}.apply(Tstructure);
        

            Mout(Nindex:Nindex+Vnout(i)-1) = tempvalue.getValues('Cnames',{Xobj.CXsolver{i}.Coutputnames});
        
        Nindex = Nindex+Vnout(i);
    end
    tempvalue = SimulationData('Cnames',CsolverOutName,'Mvalues',Mout);
    tempvalue2 =SimulationData('Tvalues',Tstructure);
    tempvalue = merge(tempvalue,tempvalue2);
end


% add the outputs of the analysis to the structure
if ~isempty(Xobj.Xsolver)

        for iOut = 1:length(Xobj.Xsolver.Coutputnames)
            Tstructure.(Xobj.Xsolver.Coutputnames{iOut}) = tempvalue.getValues('Cnames',Xobj.Xsolver.Coutputnames(iOut));
        end

    
else %cell of solvers
    CsolverOutName = {};
    for i=1:length(Xobj.CXsolver)
        
            CsolverOutName = [CsolverOutName Xobj.CXsolver{i}.Sresponse]; %#ok<AGROW>

    end
    
    for iOut = 1:length(CsolverOutName)
        Tstructure.(CsolverOutName{iOut}) = tempvalue.getValues('Cnames',{CsolverOutName{iOut}});
    end
    
    
end

value = Xobj.Xfracture.evaluate(Tstructure);
isterminal = (value>0);
direction = zeros(size(value));


end
