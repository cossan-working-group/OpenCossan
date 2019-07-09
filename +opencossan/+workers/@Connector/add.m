function Xconnector = add(Xconnector,Xobject)
%ADD:  method for adding objects to the Xconnector
%  This method requires 2 input arguments, the first is the connector
%  object and the second is the object to be added to the connector.
%  The method return the new object of type connector.
%
% USAGE: Xconnector=ADD(Xc,'Xobject')
%
%   MANDATORY INPUT ARGUMENTS:
%    Xconnector: object of class Connector
%    Xobject            The object to be add
%       |-> Xinjector        The Xinjector object
%       |-> Xextractor      The Xextractor object
%        -> Xgrid              The Xgrid object
%
%  MANDATORY OUTPUT ARGUMENT:
%  Xc = connector object
%
%   OPTIONAL ARGUMENTS:
%   ---
%   Add the Xinjector/Xexjector/Xgrid
%   EXAMPLE:  Xc  = add(Xc,Xi)
%
%   see also: Connector, injector, extractor, grid

%% 1. Processing Inputs

Xconnector.CSmembersNames{end+1} = inputname(2);
% Check inputs
if isa(Xobject, 'opencossan.workers.ascii.Injector')
    OpenCossan.cossanDisp('Add Injector Object to Connector',1);
    
    Xconnector.CXmembers{end+1}=Xobject;
    % update input names
    Xconnector.Cinputnames = Xconnector.getCinputnames();
elseif isa(Xobject, 'opencossan.workers.ascii.Extractor')
    OpenCossan.cossanDisp('Add Extractor Object to Connector',1);
    
    Xconnector.CXmembers{end+1}=Xobject;
    % update output names
    Xconnector.Coutputnames = Xconnector.getCoutputnames();
else
    error('openCOSSAN:connector:add','The second argument MUST BE an Extractor or an Injector object');
end

Xconnector.checkFiles;
end
