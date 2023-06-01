function [status, result]  =  issueCommand(Xobj,Scommand)
%ISSUECOMMAND issues commands to a remote computer from within Matlab
%
% Author: Matteo Broggi
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================
    
% This method has been derived from the function 
% sshfrommatlabissue.m of the the toolbox SSHFROMMATLAB by 
% David S. Freedman and Kostas Katrinis
%
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
% import ch.ethz.ssh2.Connection;
% import ch.ethz.ssh2.Session;
% import ch.ethz.ssh2.StreamGobbler;
import ch.ethz.ssh2.*;
%
% Invocation checking
%
if(nargin  ~=  2)
    error('OpenCossan:SSHConnection:issueCommand','ISSUECOMMAND requires a command in a string');
end
if(~ischar(Scommand))
    error('OpenCossan:SSHConnection:issueCommand',['ISSUECOMMAND input argument COMMAND '...
        'is not a string...']);
end

% check that the connection has been established and the user has been
% authenticated
if(isempty(Xobj.JsshConnection) || ~isa(Xobj.JsshConnection,'ch.ethz.ssh2.Connection'))
    Xobj.openSSHconnection;
end
%
% Send the commands. 
%
result  =  ''; % initialize stdout string
% copy the channel to keep the original channel in the handle object "untouched"
channel2  =  Xobj.JsshConnection.openSession();
channel2.execCommand(Scommand);
%
% Report the result to screen and to the string result...
%
stdout = StreamGobbler(channel2.getStdout());
br = BufferedReader(InputStreamReader(stdout));
while(true)
    line = br.readLine();
    if(isempty(line))
        break
    else
        result = [result, sprintf('%s\n',char(line))];  %#ok<AGROW>
    end
end
status = channel2.getExitStatus;
while isempty(status)
    % because of a bug, the status is not always successfully retrieved,
    % but empty is returned.  Here it check the status until the correct
    % value is obtained
    status = channel2.getExitStatus;
end
channel2.close();