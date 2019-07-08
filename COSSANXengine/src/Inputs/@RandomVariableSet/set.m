function Xrvset = set(Xrvset,varargin)
%SET This method is used to change the value of a property of the RandomVariables present
%in the RandomVariableSet object.
%
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

OpenCossan.validateCossanInputs(varargin{:});

if isempty(varargin)
    error('COSSAN:RandomVariableSet:set',...
        'The set method makes no sense without arguments');
end

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'sname','rvnames'}
            Sname= varargin{k+1};
        case {'sdistribution','mean','std','variance','parameter1','parameter2','parameter3','parameter4'}
            SpropertyName= varargin{k};
            value= varargin{k+1};
        otherwise
            error('openCOSSAN:RandomVariableSet:set',...
                'The PropertyName %s is not valid',varargin{k})
    end
end

assert(logical(exist('Sname','var')),...
    'openCOSSAN:RandomVariableSet:set',...
    'It is mandatory to specify the name of the RandomVariable')

index=find(strcmp(Xrvset.Cmembers,Sname));

Xrvset.Xrv{index}=Xrvset.Xrv{index}.set(SpropertyName,value);
% Update the RandomVariableSet
Xrvset=update(Xrvset);

