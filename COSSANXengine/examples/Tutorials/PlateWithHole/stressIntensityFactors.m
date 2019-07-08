function Toutput = stressIntensityFactors(Tinput)



Minputs = cell2mat( struct2cell(Tinput)');
Ki1 = Minputs(:,strcmp(fieldnames(Tinput),'Ki1'));
Ki2 = Minputs(:,strcmp(fieldnames(Tinput),'Ki1'));
maximumStress = Minputs(:,strcmp(fieldnames(Tinput),'maximumStress'));
minimumStress = Minputs(:,strcmp(fieldnames(Tinput),'minimumStress'));


deltaK1 = (1 - minimumStress./maximumStress) .* Ki1;
deltaK2 = (1 - minimumStress./maximumStress) .* Ki2;



Toutput=struct('deltaK1',num2cell(  deltaK1),'deltaK2',num2cell( deltaK2));


