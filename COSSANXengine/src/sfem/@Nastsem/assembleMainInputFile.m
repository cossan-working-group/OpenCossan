function  assembleMainInputFile(Xobj)
%ASSEMBLENASTFILE      Assembles the main nastran input file 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/assembleMainInputFile@Nastsem
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================
%
global OPENCOSSAN

OpenCossan.cossanDisp('[Nastsem.assembleMainInputFile] Assembling of the main input file started ',2);

%% Get the required data 

Xinp           = Xobj.Xmodel.Xinput;                         % Obtain Input

assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:NASTSEM:assembleMainInputFile',...
    'Only 1 Random Variable Set is allowed in NASTSEM.')

Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Smaininputpath = Xobj.Xmodel.Xevaluator.CXsolvers{1}.Smaininputpath; 

%% Start generating the main NASTRAN input file

% This file will contain all the necessary include commands and SE
% definitions and at the end only this file will be send to NASTRAN
[fid,~] = fopen(fullfile(OPENCOSSAN.SworkingPath,'maininput.dat'),'w+');
if fid == -1
    error('openCOSSAN:NASTSEM:assembleMainInputFile',...
        '[Nastsem.assembleMainInputFile] maininput.dat could not be opened ');
else
    OpenCossan.cossanDisp('[Nastsem.assembleMainInputFile] maininput.dat opened successfully',3);
end   

% open the original deterministic NASTRAN file
% (Some parts will be copied to the 'maininput.dat' file)
[fid2,~] = fopen(fullfile(Smaininputpath,Xobj.Sinputfile),'r');
if fid2 == -1
    error('openCOSSAN:NASTSEM:assembleMainInputFile',...
        ['[Nastsem.assembleMainInputFile] ' [Smaininputpath Xobj.Sinputfile] ' could not be opened ']);
else
    OpenCossan.cossanDisp(['[Nastsem.assembleMainInputFile] ' [Smaininputpath Xobj.Sinputfile] ' opened successfully'],3);
end   

% Insert DMAP commands for files to be output (varies for each method)
if strcmpi(Xobj.Smethod,'Perturbation')  
    fprintf(fid,'assign PUNCH=%s_DOFS.pch,unit=52,formatted,delete \n',Xobj.Sjobname);
    fprintf(fid,'ASSIGN OUTPUT4=''U_primes.op4'',unit=13,formatted \n'); 
elseif strcmpi(Xobj.Smethod,'Neumann')
    fprintf(fid,'assign PUNCH=%s_DOFS.pch,unit=52,formatted,delete \n',Xobj.Sjobname);
    fprintf(fid,'ASSIGN OUTPUT4=''U_samples.op4'',unit=13,formatted \n'); 
end

% Obtain the SOL card from the original deterministic NASTRAN file
while 1
    Sline = fgetl(fid2);
    if ~ischar(Sline),   break,   end
    if (length(Sline)>2 && strcmp(Sline(1:3),'SOL'))
        Ssolcardline = Sline;
        % insert the SOL card (obtained from deterministic NASTRAN input file)
        % to the 'maininput.dat' file
        fprintf(fid,'\n');
        fprintf(fid,Ssolcardline);
        fprintf(fid,'\n');
        % Include related DMAP code for each method
        if strcmpi(Xobj.Smethod,'Perturbation') 
            fprintf(fid,'INCLUDE dmap_perturbation.dat  \n');
        elseif strcmpi(Xobj.Smethod,'Neumann')    
            fprintf(fid,'INCLUDE dmap_neumann.dat  \n');
        end
        fprintf(fid,'CEND\n');
        fprintf(fid,'\n');
    end
    % following part needed to get the SUBCASE definition
    % and output request part from the original NASTRAN masterfile 
    % => the part between strings 'CEND' and 'BEGIN BULK'
    if (strcmp(Sline,'CEND') ) 
        while 1
            Sline = fgetl(fid2);
            if (strcmp(Sline,'BEGIN BULK') ),   break,   end
            fwrite(fid,Sline);
            fprintf(fid,'\n');
        end
    end
end

%% Start BEGIN BULK section

fprintf(fid,'\n');
fprintf(fid,'BEGIN BULK\n');
fprintf(fid,'include residual.dat\n');
%Printing SEBULK Entries
fprintf(fid,'sebulk,1,primary,,manual\n'); 
fprintf(fid,'seconct,1,0,,\n');
% Defining connection nodes to residual structure
for j=1:length(Xobj.Vfixednodes)
   if (j==1)
       fprintf(fid,',%d,%d,\n',Xobj.Vfixednodes(j),Xobj.Vfixednodes(j));
   else
       fprintf(fid,'%d,%d,\n',Xobj.Vfixednodes(j),Xobj.Vfixednodes(j));
   end
end          
fprintf(fid,'\n');

%% Prepare SE connections 

%  for Perturbation => No of SEs = No of RVs + 1
%  for Neumann => No of SEs = No of Sims + 1
if strcmpi(Xobj.Smethod,'Perturbation')
    % loop over no of RVs
    for i=1:Nrvs  
       fprintf(fid,'sebulk,%d,primary,,manual\n',i+1); 
       fprintf(fid,'seconct,%d,0,,\n',i+1);
       % Defining connection nodes to residual structure
       for j=1:length(Xobj.Vfixednodes)
           if (j==1)
               fprintf(fid,',%d,%d,\n',Xobj.Vfixednodes(j),Xobj.Vfixednodes(j));
           else
               fprintf(fid,'%d,%d,\n',Xobj.Vfixednodes(j),Xobj.Vfixednodes(j));
           end
       end          
       fprintf(fid,'\n');
    end
elseif strcmpi(Xobj.Smethod,'Neumann')
    % loop over no of Sims
    for i=1:Xobj.Nsimulations  
       fprintf(fid,'sebulk,%d,primary,,manual\n',i+1); 
       fprintf(fid,'seconct,%d,0,,\n',i+1);
       % Defining connection nodes to residual structure
       for j=1:length(Xobj.Vfixednodes)
           if (j==1)
               fprintf(fid,',%d,%d,\n',Xobj.Vfixednodes(j),Xobj.Vfixednodes(j));
           else
               fprintf(fid,'%d,%d,\n',Xobj.Vfixednodes(j),Xobj.Vfixednodes(j));
           end
       end          
       fprintf(fid,'\n');
    end
end

%% Insert BEGIN SUPER Entries 

if strcmpi(Xobj.Smethod,'Perturbation')
    for irvno=1:(Nrvs+1)
       fprintf(fid,'begin super=%d  $\n',irvno); 
       fprintf(fid,'include se%d.dat\n',irvno);
       fprintf(fid,'\n');
    end
elseif strcmpi(Xobj.Smethod,'Neumann') 
    for isim=1:(Xobj.Nsimulations+1)
       fprintf(fid,'begin super=%d  $\n',isim); 
       fprintf(fid,'include se%d.dat\n',isim);
       fprintf(fid,'\n');
    end    
end

fprintf(fid,'ENDDATA');
% close opened files
fclose(fid);

OpenCossan.cossanDisp('[Nastsem.assembleMainInputFile] Assembling of the main input file completed ',2);

return
