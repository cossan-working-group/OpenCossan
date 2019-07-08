function generateDMAPforNastsem(Xobj)
%GENDMAP Generates the file which contains the dmap code for the chosen
%        method with Superelement analysis. This dmap code interrupts the
%        regular solution sequence of NASTRAN and performs the calculations
%        required for the SFE analysis. For example, for perturbation
%        method the derivatives of u are calculated within the solver. For
%        the Neumann Exp. method, the whole calculations are done within
%        the solver, hence only the responses are passed to MATLAB to
%        calculate the statistics.
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/generateDMAPforNastsem@Nastsem
%
% =======================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

% NOTE: To know more about how the DMAP code works, see the DMAP code
% samples with comments in /home/hmp/NASTRAN/DMAP/Developed_dmaps

OpenCossan.cossanDisp('[Nastsem.generateDMAPforNastsem] Generation of the DMAP code started ',2);

%% Get the SFEM options

Xinp            = Xobj.Xmodel.Xinput;                         % Obtain Input
assert(length(Xinp.CnamesRandomVariableSet)==1,'openCOSSAN:SFEM:checkInput',...
    'Only 1 Random Variable Set is allowed in SFEM.')
Xrvs            = Xinp.Xrvset.(Xinp.CnamesRandomVariableSet{1});    % Obtain RVSET
Crvnames        = Xinp.CnamesRandomVariable;                  % Obtain RV names
Nrvs            = Xinp.NrandomVariables;                      % Obtain No of RVs
Vstdvalues      = get(Xrvs,'members','std');

%% Prepare the dmap code for Perturbation Method

if strcmpi(Xobj.Smethod,'Perturbation')
    % Generate the dmap code file
    [fid,~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,'dmap_perturbation.dat'),'w+');
    if fid == -1
        error('openCOSSAN:NASTSEM','[Nastsem.generateDMAPforNastsem] dmap_perturbation.dat could not be opened ');
    else
        OpenCossan.cossanDisp('[Nastsem.generateDMAPforNastsem] dmap_perturbation.dat opened successfully',3);
    end
    % Insert necessary DMAP commands into the file
    fprintf(fid,'   \n');
    fprintf(fid,'COMPILE PHASE1B  $\n');
    fprintf(fid,'ALTER ''CALL.*SEKMR'' $\n');
    fprintf(fid,'IF (SEID=1) THEN $  \n'); 
    fprintf(fid,'VEC USET/VGAX/''G''/''COMP''/''O'' $\n');
    fprintf(fid,'PARAM //''STSR''/52/-64 $\n');
    fprintf(fid,'MATMOD VGAX,EQEXINS,,,,/UOSET/16/1/0/1/////////''UOSET''/// $ \n');
    fprintf(fid,'ENDIF $ \n');
    fprintf(fid,'COMPILE PHASE0 $ \n');
    fprintf(fid,'ALTER ''$  PARTITION IFP CASE CONTROL TABLES FOR PLOTTING'' $  \n');
    fprintf(fid,'TYPE PARM,NDDL,I,N,ZUZRI1 $ \n');
    fprintf(fid,'IF (SEID>1) THEN $  \n');   
    fprintf(fid,'ZUZRI1 = SEID $ \n');
    fprintf(fid,'ENDIF $ \n');
    fprintf(fid,'COMPILE SEKR$ \n');
    fprintf(fid,'ALTER ''$ TOPBAILO IS SET IN DESOPT'' $ \n');
    fprintf(fid,'IF (SEID=1) THEN $ \n');
    fprintf(fid,'ALTER ''DCMP.*KOO'' $ \n');
    fprintf(fid,'COPY KOO/KOO1 $ \n');
    fprintf(fid,'COPY LOO/LKOO1 $ \n');
    fprintf(fid,'COPY UOO/UKOO1 $ \n');
    fprintf(fid,'CALL DBSTORE LKOO1,UKOO1,KOO1,,//0/0/''     ''/0 $ \n');
    fprintf(fid,'ELSE $ \n');
    fprintf(fid,'RETURN $ \n');
    fprintf(fid,'ENDIF $ \n');
    fprintf(fid,'ALTER 117,117 $\n');
    fprintf(fid,'ALTER 118,118 $\n');
    fprintf(fid,'COMPILE SELR $ \n');
    fprintf(fid,'ALTER 55,55 $ \n');
    fprintf(fid,'ALTER 56,56 $ \n');
    fprintf(fid,'ALTER 57,57 $ \n');
    fprintf(fid,'ALTER 58,58 $ \n');
    fprintf(fid,'ALTER 59,59 $ \n');
    fprintf(fid,'ALTER 60,60 $ \n');
    fprintf(fid,'ALTER 61,61 $ \n');
    fprintf(fid,'ALTER 110 $ \n');
    fprintf(fid,'FILE UPRIMES=APPEND $ \n');
    fprintf(fid,'IF (SEID=1) THEN $ \n');
    fprintf(fid,'ALTER ''$ SOLVE FOR FIXED-BOUNDARY DISPLACEMENTS'' $ \n');    
    fprintf(fid,'COPY UOO/UOO1 $  \n'); 
    fprintf(fid,'COPY UOO/UPRIMES $  \n');
    fprintf(fid,'CALL DBSTORE UOO1,UPRIMES,,,//0/0/''     ''/0 $ \n');
    fprintf(fid,'ENDIF $ \n');
    for irvno=1:Nrvs
        fprintf(fid,'IF (SEID=%d) THEN $  \n',irvno+1);
        fprintf(fid,'TYPE PARM,NDDL,I,N,ZUZRI1 $ \n');
        fprintf(fid,'CALL DBFETCH /KOO1,LKOO1,UKOO1,UOO1,UPRIMES/0/0/0/0/0 $ \n');
        fprintf(fid,'ADD5 KOO,KOO1,,,/DELK/1.0/-1.0///  $ \n');
        fprintf(fid,'ADD5 DELK,,,,/KPRIME/(%d,0.0)/////////  $ \n',(1/Vstdvalues(irvno)));        
        fprintf(fid,'MPYAD KPRIME,UOO1,/Z $ \n');
        fprintf(fid,'FBS LKOO1,UKOO1,Z/UPRIME/ $    \n');
        fprintf(fid,'APPEND UPRIME,/UPRIMES/2 $ \n');
        fprintf(fid,'CALL DBSTORE UPRIMES,,,,//0/0/''     ''/0 $ \n');   
        fprintf(fid,'ENDIF $ \n');
    end
    fprintf(fid,'IF (ZUZRI1=SEID) THEN $  \n');
    fprintf(fid,'OUTPUT4 UPRIMES,,,,///13//TRUE/   $ \n');
    fprintf(fid,'EXIT $ \n');
    fprintf(fid,'ENDIF $\n');
    fclose(fid);

%% Prepare the dmap code for Neumann Method

% this DMAP corresponds to the case where delta_K at each simulation is 
% calculated by assembling the new K suing SE and subtractiong the nominal K

elseif strcmpi(Xobj.Smethod,'Neumann')
        % Generate the dmap code file
        [fid,~] = fopen(fullfile(OpenCossan.getCossanWorkingPath,'dmap_neumann.dat'),'w+');
        if fid == -1
            error('openCOSSAN:NASTSEM','[Nastsem.generateDMAPforNastsem] dmap_neumann.dat could not be opened ');
        else
            OpenCossan.cossanDisp('[Nastsem.generateDMAPforNastsem] dmap_neumann.dat opened successfully',3);
        end
        
        fprintf(fid,'COMPILE PHASE1B  $\n');
        fprintf(fid,'ALTER ''CALL.*SEKMR'' $\n');
        fprintf(fid,'IF (SEID=1) THEN $  \n'); 
        fprintf(fid,'VEC USET/VGAX/''G''/''COMP''/''O'' $\n');
        fprintf(fid,'PARAM //''STSR''/52/-64 $\n');
        fprintf(fid,'MATMOD VGAX,EQEXINS,,,,/UOSET/16/1/0/1/////////''UOSET''/// $ \n');
        fprintf(fid,'ENDIF $ \n');
        fprintf(fid,'COMPILE PHASE0 $ \n');
        fprintf(fid,'ALTER ''$  PARTITION IFP CASE CONTROL TABLES FOR PLOTTING'' $  \n');
        fprintf(fid,'TYPE PARM,NDDL,I,N,ZUZRI1 $ \n');
        fprintf(fid,'IF (SEID>1) THEN $  \n');   
        fprintf(fid,'ZUZRI1 = SEID $ \n');
        fprintf(fid,'ENDIF $ \n');
        fprintf(fid,'COMPILE SEKR$ \n');
        fprintf(fid,'ALTER ''$ TOPBAILO IS SET IN DESOPT'' $ \n');
        fprintf(fid,'IF (SEID=1) THEN $ \n');
        fprintf(fid,'ALTER ''DCMP.*KOO'' $ \n');
        fprintf(fid,'COPY KOO/KOO1 $ \n');
        fprintf(fid,'COPY LOO/LKOO1 $ \n');
        fprintf(fid,'COPY UOO/UKOO1 $ \n');
        fprintf(fid,'CALL DBSTORE LKOO1,UKOO1,KOO1,,//0/0/''     ''/0 $ \n');
        fprintf(fid,'ELSE $ \n');
        fprintf(fid,'RETURN $ \n');
        fprintf(fid,'ENDIF $ \n');
        fprintf(fid,'ALTER 117,117 $\n');
        fprintf(fid,'ALTER 118,118 $\n');
        fprintf(fid,'COMPILE SELR $ \n');
        fprintf(fid,'ALTER 55,55 $ \n');
        fprintf(fid,'ALTER 56,56 $ \n');
        fprintf(fid,'ALTER 57,57 $ \n');
        fprintf(fid,'ALTER 58,58 $ \n');
        fprintf(fid,'ALTER 59,59 $ \n');
        fprintf(fid,'ALTER 60,60 $ \n');
        fprintf(fid,'ALTER 61,61 $ \n');
        fprintf(fid,'ALTER 110 $ \n');
        fprintf(fid,'FILE USAMPLES=APPEND $ \n');
        fprintf(fid,'IF (SEID=1) THEN $ \n');
        fprintf(fid,'ALTER ''$ SOLVE FOR FIXED-BOUNDARY DISPLACEMENTS'' $ \n');    
        fprintf(fid,'COPY UOO/UOO1 $  \n'); 
        fprintf(fid,'COPY UOO/USAMPLES $  \n');  
        fprintf(fid,'CALL DBSTORE USAMPLES,UOO1,,,//0/0/''     ''/0 $ \n');
        fprintf(fid,'ENDIF $ \n');
        fprintf(fid,'IF (SEID>1) THEN $  \n');
        fprintf(fid,'TYPE PARM,NDDL,I,N,ZUZRI1 $ \n');
        fprintf(fid,'CALL DBFETCH /KOO1,LKOO1,UKOO1,UOO1,USAMPLES/0/0/0/0/0 $ \n');
        fprintf(fid,'ADD KOO,KOO1/DELKOO//-1.0 $ \n');
        fprintf(fid,'MPYAD DELKOO,UOO1,/Z1 $ \n');
        fprintf(fid,'FBS LKOO1,UKOO1,Z1/U1/ $ \n');
        fprintf(fid,'MPYAD DELKOO,U1,/Z2 $ \n');
        fprintf(fid,'FBS LKOO1,UKOO1,Z2/U2/ $    \n');
        if (Xobj.Norder == 2) 
            fprintf(fid,'ADD5 UOO1,U1,U2/UAPP/1.0/-1.0/1.0//  $ \n');
        elseif (Xobj.Norder == 3)
            fprintf(fid,'MPYAD DELKOO,U2,/Z3 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z3/U3/ $ \n');
            fprintf(fid,'ADD5 UOO1,U1,U2,U3/UAPP/1.0/-1.0/1.0/-1.0/  $ \n');                 
        elseif (Xobj.Norder == 4)  
            fprintf(fid,'MPYAD DELKOO,U2,/Z3 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z3/U3/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U3,/Z4 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z4/U4/ $ \n');
            fprintf(fid,'ADD5 UOO1,U1,U2,U3,U4/UAPP/1.0/-1.0/1.0/-1.0/1.0  $ \n');
        elseif (Xobj.Norder == 5)
            fprintf(fid,'MPYAD DELKOO,U2,/Z3 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z3/U3/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U3,/Z4 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z4/U4/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U4,/Z5 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z5/U5/ $ \n');
            fprintf(fid,'ADD5 UOO1,U1,U2,U3,U4/UMID/1.0/-1.0/1.0/-1.0/1.0  $ \n');  
            fprintf(fid,'ADD5 UMID,U5/UAPP/1.0/-1.0///  $ \n'); 
        elseif (Xobj.Norder == 6)
            fprintf(fid,'MPYAD DELKOO,U2,/Z3 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z3/U3/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U3,/Z4 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z4/U4/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U4,/Z5 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z5/U5/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U5,/Z6 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z6/U6/ $ \n');
            fprintf(fid,'ADD5 UOO1,U1,U2,U3,U4/UMID/1.0/-1.0/1.0/-1.0/1.0  $ \n');  
            fprintf(fid,'ADD5 UMID,U5,U6/UAPP/1.0/-1.0/1.0//  $ \n');             
        elseif (Xobj.Norder == 7)
            fprintf(fid,'MPYAD DELKOO,U2,/Z3 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z3/U3/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U3,/Z4 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z4/U4/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U4,/Z5 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z5/U5/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U5,/Z6 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z6/U6/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U6,/Z7 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z7/U7/ $ \n');          
            fprintf(fid,'ADD5 UOO1,U1,U2,U3,U4/UMID/1.0/-1.0/1.0/-1.0/1.0  $ \n');  
            fprintf(fid,'ADD5 UMID,U5,U6,U7/UAPP/1.0/-1.0/1.0/-1.0/  $ \n');      
         elseif (Xobj.Norder == 8)
            fprintf(fid,'MPYAD DELKOO,U2,/Z3 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z3/U3/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U3,/Z4 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z4/U4/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U4,/Z5 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z5/U5/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U5,/Z6 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z6/U6/ $ \n');
            fprintf(fid,'MPYAD DELKOO,U6,/Z7 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z7/U7/ $ \n'); 
            fprintf(fid,'MPYAD DELKOO,U7,/Z8 $ \n');
            fprintf(fid,'FBS LKOO1,UKOO1,Z8/U8/ $ \n');  
            fprintf(fid,'ADD5 UOO1,U1,U2,U3,U4/UMID/1.0/-1.0/1.0/-1.0/1.0  $ \n');  
            fprintf(fid,'ADD5 UMID,U5,U6,U7,U8/UAPP/1.0/-1.0/1.0/-1.0/1.0  $ \n');       
        end       
        fprintf(fid,'APPEND UAPP,/USAMPLES/2 $ \n');
        fprintf(fid,'CALL DBSTORE USAMPLES,,,,//0/0/''     ''/0 $ \n');    
        % DMAP prints out the whole Displacement vectors from each
        % Simulation
        fprintf(fid,'IF (ZUZRI1=SEID) THEN $  \n');
        fprintf(fid,'OUTPUT4 USAMPLES,,,,///13//TRUE/   $ \n');
        fprintf(fid,'EXIT $ \n');
        fprintf(fid,'ENDIF $ \n');
        fprintf(fid,'ENDIF $\n');
        fclose(fid);
end

OpenCossan.cossanDisp('[Nastsem.generateDMAPforNastsem] Generation of the DMAP code started ',2);

return
