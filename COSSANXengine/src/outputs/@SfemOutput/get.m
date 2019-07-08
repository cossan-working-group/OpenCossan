function [varargout] = get(Xo,varargin)
%GET  Get properties of object of class Optimum
%   V = GET(Xo,'PropertyName') returns the value of the specified
%   property for the class variable
%
%   GET(Xo) displays all property names and their current values for
%   the Xo_optimum object with handle Xo
%
%   MANDATORY ARGUMENTS:
%   - Xo   : Optimum object
%
%   OPTIONAL ARGUMENTS:
%
%   OUTPUT ARGUMENTS:
%   the selected property
%
%   EXAMPLE:
%   get(Xo,'Sdesctiption')
%   get(Xo)
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =====================================================

%% 1.   Case where the whole object is retrieved
Sfieldname  = fieldnames(Xo);      %names of the field of the object
for i=1:length(Sfieldname),
    To.(Sfieldname{i})  = Xo.(Sfieldname{i});
end
Sfieldvalue = struct2cell(To);     %values of the fields
if isempty(varargin)
    if nargout==0,
        out     = [Sfieldname Sfieldvalue];
        OpenCossan.cossanDisp(out)
    elseif nargout==1,
        for i=1:length(Sfieldname)
            varargout{1}.(Sfieldname{i})    = Sfieldvalue{i};
        end
    else
        error('openCOSSAN:SFEMoutput:get',...
            'The number of output argmunents must be the same of the number of required fields');
    end
else
    %% 2.   Case where a specific property is retrieved
    switch lower(varargin{1}),
        case {'xsfemobject','mresponses','vresponsemean','vresponsestd','vresponsecov','xpc'},
            output  = Xo.(varargin{1});
        case {'toutput'},
            for i=1:length(Sfieldname)
                output.(Sfieldname{i})  = Sfieldvalue{i};
            end
        otherwise
            error('openCOSSAN:SFEMoutput:get','Features not implemented');
    end
    varargout{1}    = output;
end

return

