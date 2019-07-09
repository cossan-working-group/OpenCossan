function display(Xobj)
%DISPLAY   Displays SSHConnection object information
%  DISPLAY(Xobj)
%
%  See also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@SSHConnection
%
% Author: Matteo Broggi
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

%%   Output to Screen
%  Name and description
if isvalid(Xobj)
    if ~isempty(Xobj)
        OpenCossan.cossanDisp('===================================================================',2);
        OpenCossan.cossanDisp([ class(Xobj) ' Object - Description: ' Xobj.Sdescription ],1);
        OpenCossan.cossanDisp('===================================================================',2);
        
        OpenCossan.cossanDisp([' Remote host: ', Xobj.SsshHost],1)
        OpenCossan.cossanDisp([' User name: ', Xobj.SsshUser],1)
        
        if ~isempty(Xobj.SsshPassword)
            OpenCossan.cossanDisp(' Authentication via password (SECURITY RISK!)' ,1)
        elseif ~isempty(Xobj.SsshPrivateKey)
            OpenCossan.cossanDisp([' Authentication via private key file: ',Xobj.SsshPrivateKey ],1)
        end
        
        if ~isempty(Xobj.SremoteHome)
            OpenCossan.cossanDisp([' Home directory on remote host: ', Xobj.SremoteHome],1)
        end
        
        if ~isempty(Xobj.SremoteWorkFolder)
            OpenCossan.cossanDisp([' Work directory on remote host: ', Xobj.SremoteWorkFolder],1)
        end
        
        if isempty(Xobj.JsshConnection)
            OpenCossan.cossanDisp(' SSH connection is not initialized' ,1)
        else
            if Xobj.JsshConnection.isAuthenticationComplete
                OpenCossan.cossanDisp(' SSH connection is initialized and user is connected' ,1)
            else
                OpenCossan.cossanDisp(' SSH connection is initialized but user is not connected' ,1)
            end
        end
    else
        OpenCossan.cossanDisp([ 'Empty ' class(Xobj) ' object'],1);
    end
else
    OpenCossan.cossanDisp([ 'Deleted ' class(Xobj) ' object'],1);
end
end