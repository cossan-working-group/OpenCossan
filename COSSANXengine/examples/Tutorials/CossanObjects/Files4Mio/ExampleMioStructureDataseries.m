% Preallocate Memory
myCoord1=1:20;

% Cycle over the relealizations (samples)
for i=1:length(Tinput)
    myVdata1=(Tinput(i).RV1*Tinput(i).RV2)*rand(20,1);
    Toutput(i).Xds1   = Dataseries('Sdescription','myDescription1','Mcoord',myCoord1,'Vdata',myVdata1,'Sindexname','myIndexName1','Sindexunit','myIndexUnit1');
    Toutput(i).Out2   = Tinput(i).RV1;
end



