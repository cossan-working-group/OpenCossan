function [varargout] = get(Xobj,varargin)
%GET  Get class design variables
% USAGE:  V = GET(Xobj,'PropertyName') returns the value of the specified
%   property for the class variable with handle Xobj.  
%
%   GET(Xobj) displays all property names and their current values for
%   the object Xobj.
%
%  Usage: get(Xobj)
%  Example: description=get(Xobj,'Sdescription');
% =====================================================

Sfieldname  = fieldnames(Xobj);
for i=1:length(Sfieldname),
    Tpar.(Sfieldname{i})    = Xobj.(Sfieldname{i});
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
        error('openCOSSAN:DesignVariable:get',...
        'The number of output argmunents must be the same of the number of required fields');
    end
else
   
    if length(varargin)~=nargout
        for i=1:length(varargin)
            OpenCossan.cossanDisp(Xobj.(varargin{i}));
        end 
    else    
        for i=1:length(varargin)
                varargout{i}=Xobj.(varargin{i});
        end 
    end
end