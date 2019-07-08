function [varargout] = get(Xrvs,varargin)
%GET  Get method for the RVSET class
%   V = GET(H,'PropertyName') returns the value of the specified
%   property for the class variable with handle H.  
%
%   GET(Xrvs) displays all property names and their current values for
%   the object Xrvs.
%
%   V = GET(Xrvs) where Xrvs is a RVSET object, returns a structure where each
%   field name is the name of a property of RVSET and each field contains
%   the value of that property.
%
%   V = GET(Xrvs,'Sdescriptor') where Xrvs is the name of the RVSET 
%       object, returns the value of the field Sdescriptor 
%  Usage: description=get(Xrvs,'Sdescription');
%
% =====================================================

Sfieldname=fieldnames(Xrvs);

if isempty(varargin)   
    Sfieldvalue=struct2cell(Xrvs);
    
    if nargout==0
        out=[Sfieldname Sfieldvalue];
        OpenCossan.cossanDisp(out)
    elseif nargout==1
        for i=1:length(Sfieldname)
            varargout{1}.(Sfieldname{i})=Sfieldvalue{i};
        end
    else
        error('openCOSSAN:RandomVariableSet:get','The number of output argmunents must be the same of the number of required fields');
    end
else   
    switch varargin{1}        
        case {'Cmembers','members'}
            if length(varargin)>1
                    if strcmpi(varargin{2},'Sdistribution')
                        Cout=cell(length(Xrvs.Cmembers),1);
                        for i=1:length(Xrvs.Cmembers)
                              Cout{i}=get(Xrvs.Xrv{i},'Sdistribution');
                        end
                    elseif strcmpi(varargin{2},'Cpar')
                        Cout=cell(length(Xrvs.Cmembers),1);
                        for i=1:length(Xrvs.Cmembers)
                              Cout{i}=get(Xrvs.Xrv{i},'Cpar');
                        end
                    else
                        Cout=zeros(length(Xrvs.Cmembers),1);
                        for i=1:length(Xrvs.Cmembers)
                              Cout(i)=Xrvs.Xrv{i}.(varargin{2});
                        end
                    end
            else   
                    Cout=Xrvs.Cmembers;
            end
            
            if nargout==0
                OpenCossan.cossanDisp( Cout);
              else
                varargout{1}=Cout;
			end
			
        case {'mean'}
            varargout{1} = get(Xrvs,'Cmembers','mean');
        case {'std','standarddeviation'}
            varargout{1} = get(Xrvs,'Cmembers','std');  
        case {'lowerBound'}
            varargout{1} = get(Xrvs,'Cmembers','lowerBound');   
        case {'upperBound'}
            varargout{1} = get(Xrvs,'Cmembers','upperBound');   
        case {'CoV','cov'}
            varargout{1} = get(Xrvs,'Cmembers','CoV');   
        case {'Cpar','cpar'}
            varargout{1} = get(Xrvs,'Cmembers','Cpar');  
        case {'Lindependence'}
            varargout{1}=Xrvs.Lindependence;
        otherwise
            if any(strcmp(Sfieldname,varargin{1}))
                    varargout{1}=Xrvs.(varargin{1});
            else
                    error('openCOSSAN:RandomVariableSet:get','field not present');
            end
    end
end
