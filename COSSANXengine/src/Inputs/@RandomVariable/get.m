function [varargout] = get(Xrvname,varargin)
%GET  Get class random variable properties.
%   V = GET(H,'PropertyName') returns the value of the specified
%   property for the class variable with handle H.  If H is a 
%   vector of handles, then get will return an M-by-1 cell array
%   of values where M is equal to length(H).  If 'PropertyName' is
%   replaced by a 1-by-N or N-by-1 cell array of strings containing
%   property names, then GET will return an M-by-N cell array of
%   values.
%
%   GET(H) displays all property names and their current values for
%   the random variable with handle H.
%
%   V = GET(H) where H is a scalar, returns a structure where each
%   field name is the name of a property of H and each field contains
%   the value of that property.
%
%   V = GET(H,'Distri') where H is the name of the RV, returns the value of the 
%   field Distribution of H 
%   See also SET, RESET, DELETE, GCF, GCA, FIGURE, AXES.
%  
% GET(rv)  
%
%  Usage: get(rv1,'distri','Std');
%
%  See also: RandomVariable
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2007 IfM
% =====================================================
%
% History:
% EP: 13/05/2008  revised
% MFP, ??-??-2007
% HMP, 18-04-2007 Addition of the help text
% =====================================================

Cfieldname=fieldnames(Xrvname);
Cfieldvalue=cell(length(Cfieldname),1);
for i=1:length(Cfieldname)
    Cfieldvalue{i}=Xrvname.(Cfieldname{i});
end
%Sfieldvalue=struct2cell(Xrvname);

if isempty(varargin)   
    if nargout==0
        out=[Sfieldname Cfieldvalue];
        OpenCossan.cossanDisp(out)
    elseif nargout==1
        for i=1:length(Sfieldname)
            varargout{1}.(Cfieldname{i})=Cfieldvalue{i};
        end
    else
        error('The number of output argmunents must be the same of the number of required fields');
    end
else
    if length(varargin)~=nargout && length(varargin)>1
        error('The number of output argmunents must be the same of the number of required fields');
    end
    
    for i=1:length(varargin)
            %% Provide a mapping between old field and the new fields
           switch  varargin{i}
               case {'Sdesc','description'}
                   OpenCossan.cossanDisp(['Warning: ' varargin{i} 'is a virtual field, please use Sdescription']);
                   fieldname='Sdescription';
               case {'Sdistri','distribution'}
                   OpenCossan.cossanDisp(['Warning: ' varargin{i} 'is a virtual field, please use Sdistribution']);
                   fieldname='Sdistribution';
               case ('mu')
                   OpenCossan.cossanDisp('Warning: mu is a virtual field, please use mean');
                   fieldname='mean';
               case ('sig')
                   OpenCossan.cossanDisp('Warning: sig is a virtual field, please use std');
                   fieldname='std';
               case ('cv') 
                   OpenCossan.cossanDisp('Warning: cv is a virtual field, please use CoV');
                   fieldname='CoV';
               case {'parameter1','par1'}
                   if size(Xrvname.Cpar,1)>0
                      varargout{1}=Xrvname.Cpar{1,2};
                   else
                     varargout{1}=[]; 
                   end
                   return
               case {'parameter2','par2'}
                   if size(Xrvname.Cpar,1)>1
                      varargout{1}=Xrvname.Cpar{2,2};
                   else
                      varargout{1}=[]; 
                   end
                   return
                case {'parameter3','par3'}
                   if size(Xrvname.Cpar,1)>2
                      varargout{1}=Xrvname.Cpar{3,2};
                   else
                      varargout{1}=[];
                   end
                   return
                case {'parameter4','par4'}
                   if size(Xrvname.Cpar,1)>2
                      varargout{1}=Xrvname.Cpar{4,2};
                   else
                      varargout{1}=[];
                   end
                   return
               case ('variance') 
                   varargout{1}=get(Xrvname,'std')^2;
                   return
               case {'vdata'}
                   if ~isempty(Xrvname.vdata)
                       varargout{1}=Xrvname.vdata;
                   else
                       varargout{1}=[];
                   end
                   return
               otherwise
                   fieldname=varargin{i};
           end
           varargout{i}=Xrvname.(fieldname);
    end   
end
