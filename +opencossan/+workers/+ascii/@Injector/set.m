function Xinj = set(Xinj,varargin)
%SET Set EXTRACTOR field contents.
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================
% EP,  14-feb-2008 
% =====================================================

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'sdescription','description'}
             Xinj.Sdescription=varargin{k+1};   
        case {'spath','path'}
             Xinj.Spath=varargin{k+1};  
        case {'sfile','filename','sfilename'}
             Xinj.Sfile=varargin{k+1};  
        case {'nvariable','variable'}
            warning('openCOSSAN:injector:set',...
				'It is not possible changing the number of variable with set methods');
		case {'lreplaceidentifiers','replaceidentifiers'}
			Ttmp.Lreplaceidentifiers=varargin{k+1};
		case {'soutputname','outputname'}
			Ttmp.Soutputname=varargin{k+1};
        case {'tvar','tparameters'}
            Cfields={'Sname';'Nindex';'Sfieldformat';...
                'Slookoutfor';'Svarname';'Sregexpression'; ...
                'Ncolnum';'Nrownum';'Nposition'};
            flag=true;
            % check that all the possible field of Tvar are included
            while flag
                for i=1:length(Cfields)
                    if sum(strcmp(Cfields{i},fieldnames(varargin{k+1})))==0
                        error('openCOSSAN:injector:set', ...
                            'The structure Tpar does not contain all the required fields');
                        break
                    end
                end
                Xinj.Tvar=varargin{k+1};
                flag=false;
            end
           
        otherwise
            error('openCOSSAN:injector:set', ...
                   ['The argument ' varargin{k} ' not implemented']);
    end
end

if exist('Tmp','var')
    Cfields=fieldnames(Tmp);
    for i=1:length(Cfields)
        Xinj.Tresponse(iresp).(Cfields{i})=Tmp.(Cfields{i});
	end
	if Xinj.Lreplaceidentifiers && isempty(Xinj.Soutputname)
		error('openCOSSAN:injector:set', ...
                   'It is not possible to use replaceidentifiers without the Soutputname');
	end
end

