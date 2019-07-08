%% TutorialSuspensionArmUncertaintyQuantification
% 
% In this tutorial, a suspension arm, similar to what used normally in
% automotive industry, 
%
% $Copyright~1993-2013,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Authors: Matteo Broggi,\quad Pierre Beaurepaire$ 

%% Part 1: Define connection to FE solver
%
% The model of the supsension arm here analyzed is modeled using
% Code_ASTER. The FE model is connected to COSSAN by means of a Connector.
% In Code_ASTER, a mesh is stored in a binary file .rmed, and a .comm file
% is used to store the solution command and solution parameters, and a
% .export file is used to invoke the solver.
% In this particular application, the mesh file is fixed and crack are
% inseted by means of XFEM. Thus, the parameters to identify crack
% location, shape and mesh refinements steps are specified in the .comm
% file.

%%
% First, an Injector is defined for the input file command_file_new.comm
% 

SfilePath = fileparts(which('TutorialSuspensionArmUncertaintyQuantification'));

Xinj = Injector('Sscanfilepath',SfilePath,...
    'Sscanfilename','command_file_new.comm.cossan',...
    'Sfile','command_file_new.comm');
%%
% Then, the output quantity of interest are selected. We are going to
% extract the frequency response functions evaluated at a selected point
% (specified in the mesh file) in the X and Y direction. The arm can freely
% rotate along the Z axis, thus no FRF is available along that direction.
% Code_ASTER returns the FRF in the complex space, thus we need to extract
% both the real and the imaginary parts. The quantity extracted are then
% saved in the response FRFX_Re, FRFX_Im, FRFY_Re and FRFY_Im, representing
% the real and imaginary part of the FRF along computed along the X anf Y
% directions respectively.
Xresponse_FRFX_Re = Response('Sname', 'FRFX_Re',... the extracted quantity will be saved in Dataseries named FRFX_Re
    'Clookoutfor',{' FREQ         DX_0_R       DX_0_I '},...
    'Sfieldformat', ['%e' '%e'], ... the first element in the column is the frequency, the second is the real part of the FRF
    'Ncolnum',1, ... 
    'Nrownum',1, ...
    'VcoordIndex',1,...
    'Nrepeat',999 ... there are 999 value of frequency to be extracted
    );

Xresponse_FRFX_Im = Response('Sname', 'FRFX_Im',... the extracted quantity will be saved in Dataseries named FRFX_Im
    'Clookoutfor',{' FREQ         DX_0_R       DX_0_I '},...
    'Sfieldformat', ['%e' '%*e' '%e'], ... the first element in the column is the frequency, the second is ignored and the third is the real part of the FRF
    'Ncolnum',1, ...
    'Nrownum',1, ...
    'VcoordIndex',1,...
    'Nrepeat',999 ... there are 999 value of frequency to be extracted
    );

Xresponse_FRFY_Re = Response('Sname', 'FRFY_Re',...
    'Clookoutfor',{' FREQ         DX_0_R       DX_0_I'},...
    'Sfieldformat', ['%e' '%e'], ...
    'Ncolnum',1, ...
    'Nrownum',1, ...
    'VcoordIndex',1,...
    'Nrepeat',999);

Xresponse_FRFY_Im = Response('Sname', 'FRFY_Im',...
    'Clookoutfor',{' FREQ         DY_0_R       DY_0_I'},...
    'Sfieldformat', ['%e' '%*e' '%e'], ...
    'Ncolnum',1, ...
    'Nrownum',1, ...
    'VcoordIndex',1,...
    'Nrepeat',999);

%%
% The FRF will be found at the end of the analysis in the output file
% crack_modal.resu
Xext1 = Extractor('Sdescription','Extractor of frequency',...
    'Sfile','crack_modal.resu',...
    'CXresponse',{Xresponse_FRFX_Re,Xresponse_FRFX_Im,Xresponse_FRFY_Re,Xresponse_FRFY_Im});

%%
% The connection to Code_ASTER is set up, in this case the aster
% installation available in the COSSAN cluster is configured
Xc = Connector(...
    'Ssolverbinary','/usr/software/SALOME-MECA-2012.1-LGPL/aster/bin/as_run',... change this to point to as_run on the aster installation
    'Sexeflags','',... 
    'Smaininputfile','crack_modal.export',... main input file called to start the analysis
    'Smaininputpath',SfilePath,... absolute path to the original main input file
    'CSadditionalFiles',{'Part_w_hole.med'},... additional files (not injected) used in the analysis, in this case the mesh
    'Sexecmd','%Ssolverbinary %Sexeflags %Smaininputfile ',... construction of the execution command
    'Sworkingdirectory','/tmp',... execution directory of the solver
    'LkeepSimulationFiles',false,... set to false to NOT keep the files in the working directory after completion
    'CXmembers',{Xinj,Xext1}); % objects included in the Connector

%%
% After the FE is executed, a post processing Matlab function is run. In
% this function, the real and imaginary part of the FRF are combined to
% obtain the module of the FRFs.
Xmio = Mio(...
    'Sfile','postFRF.m',... file with the postprocessing function 
    'Spath',pwd,... path to the function file
    'CinputNames',{'FRFX_Re','FRFX_Im','FRFY_Re','FRFY_Im'},... input quantities
    'CoutputNames',{'FRFX','FRFY'},... output of the function
    'Lfunction',true,... flag indicating that the connection is to a Matlab function
    'Liomatrix',false,... I/O trough structure
    'Liostructure',true...
    ); 

%%
% Finally, the connection to the COSSAN cluster is set up in order to
% exploit HPC in the analysis. Only Code_ASTER will be executed on the
% cluster machines, while the matlab postprocessing will be run locally on
% the machine where this tutorial is started. Please modify the first
% element of 'Vconcurrent' to change the number of consecutive execution of
% the FE.
Xjmi = JobManagerInterface('Stype','gridengine_matlab');
Xevaluator = Evaluator('CXmembers',{Xc,Xmio},'CSnames',{'Xc','Xmio'},...
     'Xjobmanagerinterface',Xjmi,'Vconcurrent',[100 0],'CSqueues',{'all.q',''});


%% Part 2: Probabilistic model definition 
%
% In order to define the proabilistic model used in the uncertainty
% quanitification, the uncertaint parameters has to be defined. In this
% problem, the crack lengths at the 6 stress concetration points are
% assumed as uniformly distributed between 0mm (no crack) and a maximum
% length (5mm for the cracks in position 1 and 2, 10mm for the other
% cracks).
%

crack1len1 = RandomVariable('Sdistribution','uniform','lowerbound',0.5,'upperbound',5);
crack2len1 = RandomVariable('Sdistribution','uniform','lowerbound',0.5,'upperbound',5);
crack3len1 = RandomVariable('Sdistribution','uniform','lowerbound',0.5,'upperbound',10);
crack4len1 = RandomVariable('Sdistribution','uniform','lowerbound',0.5,'upperbound',10);
crack5len1 = RandomVariable('Sdistribution','uniform','lowerbound',0.5,'upperbound',10);
crack6len1 = RandomVariable('Sdistribution','uniform','lowerbound',0.5,'upperbound',10);

Xrvset = RandomVariableSet('Cmembers',{'crack1len1','crack2len1','crack3len1'...
    'crack4len1','crack5len1','crack6len1'});

%%
% Then, the mesh refinement parameter is defined (more details to this
% parameter will be given later) and the Input object containing all the
% input quantities of the probabilistic model is created.
refinement = Parameter('value',1);

Xinput = Input('CXmembers',{Xrvset,refinement},...
    'CSmembers',{'Xrvset','refinement'});
 
 
%% Part 3: Generation of the target FRF
% 
% A dedicated input object is created to obtain the reference FRF. In the
% reference simulation, a single crack is present in position 3 with a
% length of 5mm, and 3 iterations of mesh refinement are used in the XFEM.
%
% First, the input object previously defined is duplicated and a sample is
% added to it.
Xinput_target = Xinput.sample('Nsamples',1);
%%
% Then the input value corresponding to the reference FRF computation are
% set. To do this, the sample matrix is set so that no crack are present in
% position 1, 2, 4, 5 and 6 and one crack of 5mm is in position 3
Xinput_target.Xsamples.MsamplesPhysicalSpace = [0 0 5 0 0 0];

%%
% The number of mesh refinements is set to 3
Xinput_target.Xparameters.refinement.value = 3;

%%
% Finally a dedicated model is created and excuted with the set parameters.
Xmodel_target = Model('Xevaluator',Xevaluator,'Xinput',Xinput_target);
Xout_target = Xmodel_target.apply(Xinput_target);

%%
% The reference FRFs are then obtained
figure(1)
subplot(2,1,1)
plot(Xout_target.Tvalues.FRFX.Mcoord,Xout_target.Tvalues.FRFX.Vdata); grid
subplot(2,1,2)
plot(Xout_target.Tvalues.FRFY.Mcoord,Xout_target.Tvalues.FRFY.Vdata); grid

%% Part 4: Uncertainty Quantification
%
% The uncertainty quantification is executed here. A quasi-montecarlo
% simulation method is used to evaluate the spread of the FRFs when any
% number of cracks of any possible length are present in the structure.
% Please note that since the original input object is used, the refinement
% parameter is set to 1, thus no mesh refinement is carried out to ensure
% the fastest FE execution is achieved at the expense of a loss of accuracy
% in the simulation.
Xmodel = Model('Xevaluator',Xevaluator,'Xinput',Xinput);

Xlhs = LatinHypercubeSampling('Nsamples',100);

Xout_lhs = Xlhs.apply(Xmodel);
%%
% The results are retrieved and plot in a nice way
Xout_lhs.getDataseries('CSnames',{'FRFX','FRFY'});
Xds_FRFs = Xout_lhs.getDataseries('CSnames',{'FRFX','FRFY'});
figure(2)
for iplot = 1:2
    subplot(2,1,iplot)
    plot(Xds_FRFs(iplot).Mcoord,Xds_FRFs(iplot).Mdata,'Color',[1 0.95 0.95])
    hold on
    plot(Xds_FRFs(iplot).Mcoord,quantile(Xds_FRFs(iplot).Mdata,.50),'r')
    plot(Xds_FRFs(iplot).Mcoord,quantile(Xds_FRFs(iplot).Mdata,[.05 .95]),'--r')
    hold off
    grid
end
