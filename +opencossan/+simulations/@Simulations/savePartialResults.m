function Ldone = savePartialResults(Xobj)
%SAVEPARTIALRESULTS  This private methods of the class simulations is used
%to store the partial results of the simulation, i.e. the batches, on the
%disk 

% initialize variable
Ldone = false;

% Create a folder to store the partial results
if exist('Xobj.SbatchFileNames','dir')
	[status,mess] = mkdir(Xobj.SbatchFileNames);
    if ~status
        warning('openCOSSAN:simulations:savePartialResults',mess)
    end
end
    
% Store SimulationData object 

