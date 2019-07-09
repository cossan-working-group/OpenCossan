function [varargout] = get(Xobj,varargin)
%GET  Get method for the BOUNDEDSET class
%   V = GET(H,'PropertyName') returns the value of the specified
%   property for the class variable with handle H.
%
%   GET(Xbs) displays all property names and their current values for
%   the object Xint.
%
%   V = GET(Xbs) where Xbs is a BOUNDEDSET object, returns a structure where each
%   field name is the name of a property of BS and each field contains
%   the value of that property.
%
%   V = GET(Xbs,'Sdescriptor') where Xrvs is the name of the BS
%       object, returns the value of the field Sdescriptor
%  Usage: description=get(Xbs,'Sdescription');

Sfieldname=fieldnames(Xobj);

if isempty(varargin)
    Sfieldvalue=struct2cell(Xobj);
    
    if nargout==0
        out=[Sfieldname Sfieldvalue];
        OpenCossan.cossanDisp(out)
    elseif nargout==1
        for i=1:length(Sfieldname)
            varargout{1}.(Sfieldname{i})=Sfieldvalue{i};
        end
    else
        error('openCOSSAN:BoundedSet:get','The number of output argmunents must be the same of the number of required fields');
    end
else
    switch varargin{1}
        case {'Cmembers','members'}
            if length(varargin)>1
                if strcmpi(varargin{2},'Sdistribution')
                    Cout=cell(length(Xobj.Cmembers),1);
                    for i=1:length(Xobj.Cmembers)
                        Cout{i}=get(Xobj.Xrv{i},'Sdistribution');
                    end
                elseif strcmpi(varargin{2},'Cpar')
                    Cout=cell(length(Xobj.Cmembers),1);
                    for i=1:length(Xobj.Cmembers)
                        Cout{i}=get(Xobj.Xrv{i},'Cpar');
                    end
                else
                    Cout=zeros(length(Xobj.Cmembers),1);
                    for i=1:length(Xobj.Cmembers)
                        Cout(i)=Xobj.Xrv{i}.(varargin{2});
                    end
                end
            else
                Cout=Xobj.Cmembers;
            end
            
            if nargout==0
                OpenCossan.cossanDisp( Cout);
            else
                varargout{1}=Cout;
            end
            
        case {'center'}
            varargout{1} = get(Xobj,'Cmembers','center');
        case {'std','standarddeviation'}
            varargout{1} = get(Xobj,'Cmembers','std');
        case {'lowerBound'}
            varargout{1} = get(Xobj,'Cmembers','lowerBound');
        case {'upperBound'}
            varargout{1} = get(Xobj,'Cmembers','upperBound');
        case {'CoV','cov'}
            varargout{1} = get(Xobj,'Cmembers','CoV');
        case {'Cpar','cpar'}
            varargout{1} = get(Xobj,'Cmembers','Cpar');
        case {'Lindependence'}
            varargout{1}=Xobj.Lindependence;
        otherwise
            if any(strcmp(Sfieldname,varargin{1}))
                varargout{1}=Xobj.(varargin{1});
            else
                error('openCOSSAN:BoundedSet:get','field not present');
            end
    end
end
