function Xds = createDataseries(Xobj,Moutput)

import opencossan.common.Dataseries
if Xobj.LoutputInColumns
    Moutput = Moutput';
end

% check consistency of Ndata and Ndimension
if ~isinf(Xobj.Ndata)
    assert(Xobj.Ndata==size(Moutput,2),'openCOSSAN:Response:createDataseries',...
        'Number of expected data is not consistent with the extraxted quantities.')
end

if ~isempty(Xobj.VcoordIndex)
    % if it is specified which rows of Moutput should be used as Mcoord in
    % the Dataseries, only one row of data should be available to populate
    % Vdata
    assert(Xobj.Nrows-length(Xobj.VcoordIndex)==1,'openCOSSAN:Response:createDataseries',...
        'When the indeces to be used as coordinates are specified, only one index can be used for the data.')
    Mcoord = Moutput(Xobj.VcoordIndex,:);
    Vdata = Moutput;
    Vdata(Xobj.VcoordIndex,:)=[];

    Xds = Dataseries('Mcoord',Mcoord,'Vdata',Vdata,'CSindexName',Xobj.CSindexName);
else
    % if no rows of Moutput are used to create Mcoord, Mcoord is
    % automatically populated with indeces and the matrix is directly saved
    Xds = Dataseries('Mmatrix',Moutput);
end
end
