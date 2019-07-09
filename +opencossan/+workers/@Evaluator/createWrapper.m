function createWrapper(Xobj,Nfid)
%CREATEWRAPPER This function create a wrapper for the EVALUATOR Object
% The method requires an  integer file identifie (fid) of an open file. 
%
% See Also: http://cossan.co.uk/wiki/index.php/createWrapper@Evaluator
%
% Author: Edoardo Patelli
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

%% Create a wrapper file
fprintf(Nfid,'%%%% OpenCossan Wrapping script. DO NOT EDIT!\n');

% assemble the string used to call the main function in a try-catch block
fprintf(Nfid,'%% initialize error variable\n');
fprintf(Nfid,'ME = [];\n');
fprintf(Nfid,'%% Add the location of the function to the path\n');
% Initialize OpenCossan
fprintf(Nfid,'OpenCossan;\n');
% Set vervosity level
fprintf(Nfid,'OpenCossan.setVerbosityLevel(%i);',OpenCossan.getVerbosityLevel);
% This is used for debugging purpose 
fprintf(Nfid,'display([''Finished engine startup on '' system(''hostname'')]');
fprinff(Nfid,'display([''Execution Time: '' datestr(now,0)]');
% save output
fprintf(Nfid,'%% load Input ');
fprintf(Nfid, ' load %s; \n',Xobj.SwrapperInputName);

% Loop around samples
fprintf(Nfid, ' for n=1:lenght()');
% Loop around the solvers
for isol=1:length(Xobj.CXsolvers)
    fprintf(Nfid,'%% SOLVER %i (Type: %s)\n',isol,class(Xobj.CXsolvers{isol}));
    
    % Define input and output filename 
    Xobj.CXsolvers{n}.SwrapperInputName=sprintf('workerINPUT%i.mat',isol);
    Xobj.CXsolvers{n}.SwrapperOutputName=sprintf('workerOUTPUT%i.mat',isol);
    % Create wrapper for solvers
    createWrapper(Xobj.CXsolvers{n},Nfid);
end   
% Merge results
fprintf(Nfid, 'if n==1, %s=%s; else %s=merge(%s,%s); end',...
    Xobj.SwrapperOutputName,Xobj.CXsolvers{n}.SwrapperOutputName,...
    Xobj.SwrapperOutputName,Xobj.SwrapperOutputName,Xobj.CXsolvers{n}.SwrapperOutputName); 
% Close loop around samples
fprintf(Nfid, ' end'); 

% save output
fprintf(Nfid,'%% save output');
fprintf(Nfid, ' save %s %s; \n',Xobj.SwrapperOutputName, Xobj.SwrapperOutputName);

% Catch error
fprintf(Nfid,'catch ME\n');
fprintf(Nfid,'%% Show error messages');
fprintf(Nfid,'    display(ME.message)\n');
fprintf(Nfid,'    for i=length(ME.stack):-1:1;\n');
fprintf(Nfid,'        display(ME.stack(i).file)\n');
fprintf(Nfid,'        display(ME.stack(i).line)\n');
fprintf(Nfid,'    end\n');
fprintf(Nfid,'end\n');
fprintf(Nfid,'if isempty(ME)\n');
fprintf(Nfid,'end\n');
fprintf(Nfid,'exit;\n');

