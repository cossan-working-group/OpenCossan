function [varargout] = get(Xpar,varargin)
%GET  Get class parameters
% USAGE:  V = GET(Xpar,'PropertyName') returns the value of the specified
%   property for the class variable with handle Xpar.  
%
%   GET(Xpar) displays all property names and their current values for
%   the object Xpar.
%
%   V = GET(Xpar) where Xpar is a parameter object, returns a structure where each
%   field name is the name of a property of Xpar and each field contains
%   the value of that property.
%
%   V = GET(Xpar,'Sdescriptor') where Xpar is the name of the parameter
%       object, returns the value of the field Sdescriptor 
%  
%
%  Usage: get(Xpar)
%  Example: description=get(Xpar,'Sdescription');
% =====================================================
% See also parameter
% =====================================================

warning('OpenCossan:Parameter:get:obsolete','This method is obsolete and it will be removed')

Sfieldname  = fieldnames(Xpar);
for i=1:length(Sfieldname),
    Tpar.(Sfieldname{i})    = Xpar.(Sfieldname{i});
end
Sfieldvalue = struct2cell(Tpar);

if isempty(varargin)   
    if nargout==0
        out=[Sfieldname Sfieldvalue];
        OpenCossan.cossanDisp(out)
    elseif nargout==1
        for i=1:length(Sfieldname)
            varargout{1}.(Sfieldname{i})=Sfieldvalue{i};
        end
    else
        error('openCOSSAN:Parameter:get',...
        'The number of output argmunents must be the same of the number of required fields');
    end
else
   
    if length(varargin)~=nargout
        for i=1:length(varargin)
            display(Xpar.(varargin{i}));
        end 
    else    
        for i=1:length(varargin)
                varargout{i}=Xpar.(varargin{i});
        end 
    end
end