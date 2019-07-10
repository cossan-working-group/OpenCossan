function Xds = createDataseries(Xobj,Moutput)
% This function convert the data values into a Dataseries object


% check consistency of Ndata and Ndimension
if ~isinf(Xobj.Ndata)
    assert(Xobj.Ndata==numel(Moutput),'OpenCossan:Response:createDataseries',...
        'Number of expected data is not consistent with the extraxted quantities.')
end

if ~isempty(Xobj.VcoordColumn)
    % if it is specified which rows of Moutput should be used as Mcoord in
    % the Dataseries, only one row of data should be available to populate
    % Vdata
    
    Mcoord = Moutput(:,Xobj.VcoordColumn);
    Vdata = Moutput;
    Vdata(:,Xobj.VcoordColumn)=[];

    Xds = Dataseries('Mcoord',Mcoord','Vdata',Vdata','CSindexName',Xobj.CSindexName);
    
elseif ~isempty(Xobj.VcoordRow)
    % if it is specified which rows of Moutput should be used as Mcoord in
    % the Dataseries, only one row of data should be available to populate
    % Vdata
    
    Mcoord = Moutput(Xobj.VcoordRow,:);
    Vdata = Moutput;
    Vdata(Xobj.VcoordRow,:)=[];

    Xds = Dataseries('Mcoord',Mcoord,'Vdata',Vdata,'CSindexName',Xobj.CSindexName);
    
else
    if ~Xobj.LisMatrix
        Moutput=Moutput(:)'; % Create a single vector 
    end
    % if no rows of Moutput are used to create Mcoord, Mcoord is
    % automatically populated with indeces and the matrix is directly saved
    if isrow(Moutput)
        Xds = Dataseries('Mdata',Moutput);
    else
        Xds = Dataseries('Mmatrix',Moutput);
    end
end
end