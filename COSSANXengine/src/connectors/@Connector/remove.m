function Xconnector = remove(Xconnector,Sobjectname)

%REMOVE:  method for removing objects from the Xconnector object
%  This method requires 2 mandatory inputs (the connector and the name of
%  the object that must be remove.
% It returns a connector object
%
%   Mandatory Arguments:
%   ==========
%
%   Xconnector               The conncetor object
%   Xobject                      object to be removed (it can be an
%                                     injector/extractor or a Xgrid object)
%
% EXAMPLE
%  Xc  = remove(Xc,'Xinjector1')
%
%   see also: connector, evaluator, injector, extractor, grid


if any(strcmp(Xconnector.CSmembersNames,Sobjectname))    
    Lremove = strcmp(Xconnector.CSmembersNames,Sobjectname);
    if Xconnector.Linjectors(Lremove)
        OpenCossan.cossanDisp(['The injector ' Sobjectname ' has been removed form the Connector'],1);
    end
    if Xconnector.Lextractors(Lremove)
        OpenCossan.cossanDisp(['The extractor ' Sobjectname ' has been removed form the Connector'],1);
    end
    Xconnector.CXmembers{Lremove}=[];
    Xconnector.CSmembersNames{Lremove}='';
end
    
end
