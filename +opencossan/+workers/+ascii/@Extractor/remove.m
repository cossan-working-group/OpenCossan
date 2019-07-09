function Xextractor = remove(Xextractor,Svarname)
%REMOVE  remove a response from the extract object
%
%   Arguments:
%   ==========
%                   
%   MANDATORY ARGUMENTS: 
%      - Xextractor (extractor object)
%      - Name of the associate COSSAN output 
%
%
%   EXAMPLES:
%                Xe  =remove(Xe,'Out1')
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================
%
%   see also: add, extractor

%% 1. Processing Inputs

% Process all the optional arguments and assign them the corresponding
% default value if not passed as argument

if ~isa(Svarname,'char')
        error('openCOSSAN:extractor:remove',...
             'The second argument must be a string');
else
       Ipos=find(strcmp(Xextractor.Coutputnames,Svarname)~=0);
       if length(Ipos)~=1
           error('openCOSSAN:extractor:remove',...
             ['The response ' Svarname ' is NOT present in the extractor']);
       end
end

%% 2. Define extractors
Xresponse_new=Xextractor.Xresponse(~strcmp(Xextractor.Coutputnames,Svarname));

% set the values of the response
Xextractor.Xresponse = Xresponse_new;
       
