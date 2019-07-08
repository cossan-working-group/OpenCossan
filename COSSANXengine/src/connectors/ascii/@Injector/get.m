function [varargout] = get(Xinj,varargin)
%GET  Get class injector  properties.
%   V = GET(Xinj,'PropertyName') returns the value of the specified
%   property for the class variable with handle Xinj.  
%
%   GET(Xinj) displays all property names and their current values for
%   the object Xinj.
%
%   V = GET(Xinj) where Xinj is a scalar, returns a structure where each
%   field name is the name of a property of Xinj and each field contains
%   the value of that property.
%
%   V = GET(Xinj,'Sdescriptor') where Xinj is the name of the injector
%       object, returns the value of the field Sdescriptor of Xinj 
%
%  Usage: get(Xinj)
%  Example: description=get(Xinj,'Sdescription');
% =====================================================

Sfieldname=fieldnames(Xinj);
Sfieldvalue=struct2cell(Xinj);

if isempty(varargin)   
    if nargout==0
        out=[Sfieldname Sfieldvalue];
        OpenCossan.cossanDisp(out)
    elseif nargout==1
        for i=1:length(Sfieldname)
            varargout{1}.(Sfieldname{i})=Sfieldvalue{i};
        end
    else
        error('The number of output argmunents must be the same of the number of required fields');
    end
else
    if nargout==0
         for i=1:length(varargin)
            out{i}=Xinj.(varargin{i}); %#ok<AGROW>
         end
         OpenCossan.cossanDisp(out);
    else
        if length(varargin)~=nargout
         error('openCOSSAN:injector:get',...
			 'The number of output argmunents must be the same of the number of required fields');
        end
        
         for i=1:length(varargin)
            varargout{i}=Xinj.(varargin{i});
         end
    end
end
