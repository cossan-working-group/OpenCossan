function display(Xobj)
%DISPLAY   Displays DatabaseDriver object information
%  DISPLAY(Xobj)
%
%  See also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@DatabaseDriver
%
% Author: Matteo Broggi
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

import opencossan.OpenCossan
%%   Output to Screen
%  Name and description
if ~ isempty(Xobj)
    OpenCossan.cossanDisp('===================================================================',2);
    OpenCossan.cossanDisp([ class(Xobj) ' Object - Description: ' Xobj.Sdescription ],1);
    OpenCossan.cossanDisp('===================================================================',2);
    OpenCossan.cossanDisp([' Database driver: ', Xobj.SjdbcDriver],1)
    
    switch Xobj.SjdbcDriver
        case {'com.mysql.jdbc.Driver','org.postgresql.Driver'}
            OpenCossan.cossanDisp([' Database host: ', Xobj.ShostName],1)
            OpenCossan.cossanDisp([' Database name: ', Xobj.SdatabaseName],1)
        case 'org.sqlite.JDBC'
            OpenCossan.cossanDisp([' Database path: ', Xobj.ShostName],1)
            OpenCossan.cossanDisp([' Database file: ', Xobj.SdatabaseName],1)
    end
    
    if ~isempty(Xobj.SuserName)
        OpenCossan.cossanDisp([' Database user name: ',Xobj.SuserName ],1)
    end
else
    OpenCossan.cossanDisp([ 'Empty ' class(Xobj) ],1);
end
end