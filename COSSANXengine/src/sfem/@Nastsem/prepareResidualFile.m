function prepareResidualFile(Xobj)
%XRESIDUAL Generates the residual file from the regular NASTRAN input file
%   
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/prepareResidualFile@Nastsem
%
% =========================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =========================================================================

OpenCossan.cossanDisp('[Nastsem.prepareResidualFile] Preparation of the input file for the residual structure started ',2);
% TODO: Here is assuming that only one solver is stored into the evaluator,
% and that is a connector!!!
Smaininputpath  = Xobj.Xmodel.Xevaluator.CXsolvers{1}.Smaininputpath; 

%% Generate the residual masterfile

[fid,~]  = fopen(fullfile(Smaininputpath,Xobj.Sinputfile),'r');
if fid == -1
    error('openCOSSAN:NASTSEM',['[Nastsem.prepareResidualFile] ' Smaininputpath Xobj.Sinputfile ' could not be opened ']);
else
    OpenCossan.cossanDisp(['[Nastsem.prepareResidualFile] ' Smaininputpath Xobj.Sinputfile ' opened successfully'],3);
end  

[fid2,~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,'residual_master.dat'),'w+'); 
if fid2 == -1
    error('openCOSSAN:NASTSEM','[Nastsem.prepareResidualFile] residual_master.dat could not be opened ');
else
    OpenCossan.cossanDisp('[Nastsem.prepareResidualFile] residual_master.dat opened successfully',3);
end  

% copy all text between "BEGIN BULK" and "ENDDATA" into residual_master.dat
% file
while 1
    Sline = fgetl(fid);
    if ~ischar(Sline),   break,   end
    if (strcmp(Sline,'BEGIN BULK') ) 
        while 1
            Sline = fgetl(fid);
            if (length(Sline)>6 && strcmp(Sline(1:7),'ENDDATA')), break,   end
            fwrite(fid2,Sline);
            fprintf(fid2,'\n');
            if ~ischar(Sline),   break,   end
        end
    end    
end

%% close the files opened
fclose(fid);
fclose(fid2);

OpenCossan.cossanDisp('[Nastsem.prepareResidualFile] Preparation of the input file for the residual structure completed ',2);

return
