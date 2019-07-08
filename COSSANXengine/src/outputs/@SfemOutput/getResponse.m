function Xobj = getResponse(Xobj,varargin)
%DISPLAY  Displays the object SfemOutput
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getResponse@SfemOutput
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli
% Author: Murat Panayirci 

%% Get the SFEM object

Xsfem = Xobj.XSfemObject;

%% Get the varargin

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'sresponse'}
            if ~strcmp(Xsfem.Smethod,'Collocation')
                Xobj.Sresponse=varargin{k+1};
            else
                error('openCOSSAN:SfemOutput', ...
                    'Sresponse argument is ignored for Collocation PC'); 
            end
        case {'mresponsedofs'}
            if ~strcmp(Xsfem.Smethod,'Collocation')
                Xobj.MresponseDOFs=varargin{k+1};
            else
                error('openCOSSAN:SfemOutput', ...
                    'MresponseDOFs argument is ignored for Collocation PC');
            end
        case {'nmode'}
            Xobj.Nmode=varargin{k+1};
        otherwise
            error('openCOSSAN:SfemOutput', ...
                'Field name not allowed');
    end
end

if strcmp(Xsfem.Smethod,'Collocation')
    Xobj.Sresponse='all';
end

%% Check the required response DOF entered by user

if isa(Xsfem,'SfemPolynomialChaos') 
    if strcmp (Xsfem.Smethod,'Guyan')
        Xsfem.MmodelDOFs = Xsfem.MmasterDOFs;
    end
end

% check the selected response type
if ~strcmp (Xobj.Sresponse,'specific') && ~strcmp (Xobj.Sresponse,'all') && ~strcmp (Xobj.Sresponse,'max')
    error('openCOSSAN:SfemOutput', ...
        'Please select one of the following response types: specific, max or all');
end

% check if the MresponseDOFs has to right size
checksize = size(Xobj.MresponseDOFs);
if checksize(2) ~= 2 && strcmp(Xobj.Sresponse,'specific') && strcmp(Xsfem.Sanalysis,'Static')
    error('openCOSSAN:SfemOutput', ...
        'MresponseDOFs should be with size n x 2');
end

% first check if the required whether the response Node no exists or not
% => You need to check only if a specific response is asked
% NOTE: Xobj.Vresponsedof(1) = NODE NO
%       Xobj.Vresponsedof(2) = DOF NO of the corresponding node     
% TODO: Update the following check also for the modal analysis
if ~strcmp(Xsfem.Smethod,'Collocation')
    if strcmp(Xsfem.Sanalysis,'Static') && strcmp(Xobj.Sresponse,'specific')
        for i=1:size(Xobj.MresponseDOFs,1)
            if  isempty(find(Xobj.MresponseDOFs(i) == Xsfem.MmodelDOFs(:,1),1))
                error(['[SfemOutput.getResponse] Selected Response Node ' num2str(Xobj.MresponseDOFs(i)) ' does not exist in the model']);
            end
        end
    end
end

%% For modal analysis, check the requested mode no

if ~isempty(Xobj.Nmode) && strcmp (Xsfem.Sanalysis,'Static')
    error('[SfemOutput.getResponse] Modal Analysis has to be performed to get statistics of the modes');
end

% Obtain the nominal eigenvalue corresponding to the requested mode
% Note: First column contains the eigenvalues
% A check is made here whether or not the requested mode is output by
% the FE model or not
if Xobj.Nmode > size(Xsfem.MnominalEigenvalues,1)
    error('[SfemOutput.getResponse] Selected Mode no is out of the range of the total no of modes calculated by the FE model');
end


%% obtain the requested response

maxresponseDOF = []; %#ok<*NASGU>
Xobj.Vresponsemean  = zeros(size(Xobj.MresponseDOFs,1),1);
Xobj.Vresponsestd   = zeros(size(Xobj.MresponseDOFs,1),1);
Xobj.Vresponsecov   = zeros(size(Xobj.MresponseDOFs,1),1);

% For the collocation method, there is no MresponseDOFs, since
% it works like a simulation (an extractor is used)
% therefore it is treated differently here
if strcmp (Xsfem.Smethod,'Collocation')
    % Calculating mean and cov for the whole displacement vector
    Xobj.Vresponsemean = Xobj.Vmean;
    Xobj.Vresponsestd  = Xobj.Vstd;
    Xobj.Vresponsecov  = abs(Xobj.Vresponsestd./Xobj.Vresponsemean);
    return
end

% For all the remaining cases, following part is used
if strcmpi (Xsfem.Sanalysis,'Static')
    if strcmp (Xobj.Sresponse,'specific')
        % obtain the response for the asked DOFs
        % the no of responses are determined according to the no of
        % rows in vresponsedof matrix
        for i=1:size(Xobj.MresponseDOFs,1)
            nodenumber  = Xobj.MresponseDOFs(i,1);
            dofnumber   = Xobj.MresponseDOFs(i,2);
            % First find the dofs corresponding to the requested NODE no
            Vnodeindex  = find(nodenumber == Xsfem.MmodelDOFs(:,1));
            % then obtain the requested dof for the considered NODE no
            dofindex    = dofnumber == Xsfem.MmodelDOFs(Vnodeindex,2);
            % responsedof is the no of entry in the displacement vector
            responsedof = Vnodeindex(dofindex);
            % Calculating mean and cov of response only for the asked DOFs
            Xobj.Vresponsemean(i) = Xobj.Vmean(responsedof);
            Xobj.Vresponsestd(i)  = Xobj.Vstd(responsedof);
            Xobj.Vresponsecov(i)  = abs(Xobj.Vresponsestd(i)/Xobj.Vresponsemean(i));
        end
    elseif strcmp (Xobj.Sresponse,'all')
        Xobj.MresponseDOFs = Xsfem.MmodelDOFs;
        % Calculating mean and cov for the whole displacement vector
        Xobj.Vresponsemean = Xobj.Vmean;
        Xobj.Vresponsestd  = Xobj.Vstd;
        Xobj.Vresponsecov  = abs(Xobj.Vresponsestd./Xobj.Vresponsemean);
        disp('COSSAN:SfemOutput: in order to retrieve the statistics of the whole displacement vector, please use the prepareReport function')
    elseif strcmp (Xobj.Sresponse,'max')
        % Calculating mean and cov for the DOF with max (abs) disp. value
        [~, Xobj.maxresponseDOF] = max(abs(Xobj.Vmean));
        Xobj.MresponseDOFs  = Xsfem.MmodelDOFs(Xobj.maxresponseDOF,:);
        % re-assign the mean in order to get the real value of the disp
        % instead of its absolute value
        Xobj.Vresponsemean = Xobj.Vmean(Xobj.maxresponseDOF);
        Xobj.Vresponsestd  = Xobj.Vstd(Xobj.maxresponseDOF);
        Xobj.Vresponsecov  = abs(Xobj.Vresponsestd./Xobj.Vresponsemean);
    end
% For MODAL analysis, only specific response type is valid
elseif strcmp (Xsfem.Sanalysis,'Modal')
       if strcmp (Xobj.Sresponse,'specific')
           % Calculating mean and cov of response only for the required mode
           Xobj.Vresponsemean = Xobj.Vmean(Xobj.Nmode);
           Xobj.Vresponsestd  = Xobj.Vstd(Xobj.Nmode);
           Xobj.Vresponsecov  = abs(Xobj.Vresponsestd/Xobj.Vresponsemean);
       else
           error('COSSAN:sfem: Sresponse should be stated as "specific" for Modal Analysis. The options "max" or "all" are not valid in this case.'); 
       end
end

% Following part is needed to store also the samples of the response, which
% is valid only for the Neumann method
if isa(Xsfem,'Neumann')
    if strcmp (Xobj.Sresponse,'specific')
        Xobj.Vresponses = Xobj.Mresponses(responsedof,:);
    elseif strcmp (Xobj.Sresponse,'max')
        Xobj.Vresponses = Xobj.Mresponses(maxresponseDOF,:);
    end
end

return
