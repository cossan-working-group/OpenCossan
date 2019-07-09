function [Xs varargout] = sort(Xs,varargin)
%SORT   sorts samples located in Samples object Xs
%
%   This method sorts the samples in the object Samples according to some
%   prescribed criterion with respect to one of the random variable.
%   The method then takes a variable number of token value pairs.  These
%   pairs set properties (optional values) of the sort method.
%
% 	MANDATORY ARGUMENTS
%   - 'Starget' : a valid input rv name
%   - 'Stype'   : indicates whether the samples are to be sorted in 
%   ascending or descending order. Valid options are the strings 'ascend'
%   and 'descend'
%   - 'Vindex'  :  sort according to a predefind vector. It should be noted
%   that this argument overrules all other arguments of the method sort.
% 
%
%   OUTPUT
%   - 'Xs'      : Samples object   (sorted according to prescribed criterion)
%   - 'Vsorted' : Sorted values    (of the selected random variable)
%   - 'Vindex'  : Index of the sorted value
%
%
%   USAGE
%   Xs=SORT(Xs,PropertyName, PropertyValue, ...)
%
%   EXAMPLES
%   Xs1 = sort(Xs,'Starget','RV1','Stype','descend')
%   Xs1 = sort(Xs,'Vindex',Vindex)
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008b IfM
% =====================================================

%% 1.   Argument Check
if mod(length(varargin),2),
    error('openCOSSAN:Samples:sort',...
        'each optimization FIELD should be followed by its corresponding VALUE');
    %always a FIELD must be followed by its corresponding value
end

%% 2.   Define default values
Ssort   = 'ascend'; %by default, samples are sorted in ascending order
Vindex  = [];       %variable to sort samples

%% 3.   Process input options
for k=1:2:length(varargin)
	switch lower(varargin{k}),
        %3.1.   Get name of random variable used for sorting
		case {'starget'}
			Crvname = Xs.CnamesRandomVariable;    %extract names of random variables present in object Samples
			Vpos   = find(strcmp(Crvname,varargin{k+1}));  %compare random variables present in object Samples with random variable name passed by the user
			if isempty(Vpos),  %in case the name passed by the user does not match, return an error
				error('openCOSSAN:Samples:sort', ...
					['The target RV name ' varargin{k+1} ' is not present in the object Samples']);
			end
			Vtarget     = Xs.MsamplesHyperCube(:,Vpos);   %extract values of samples random variable to be sorted
		%3.2.   Definition of type of sorting
        case {'stype'}
            if strcmp( varargin{k+1},'ascend') || strcmp( varargin{k+1},'descend')
			Ssort   = varargin{k+1};
            else
                error('openCOSSAN:Samples:sort', ...
					'Stype must be equal to ''ascend'' or ''descend'' ');
            end
		%3.3.   Extraction of vector for sorting
        case {'vindex','vindices'}
			if (length(varargin{k+1})==size(Xs.MsamplesHyperCube,1)),   %check that sizes match
				Vindex  = varargin{k+1};
			end
		otherwise
			warning('openCOSSAN:Samples:sort', ...
				['PropertyName:  ' varargin{k} ' not available'])
	end
end


%% Sort according to input options
if isempty(Vindex),
	[Vsorted,Vindex]    = sort(Vtarget,1,Ssort);    %sort according to specified parameters
else
	Vsorted             = [];   
end

%% Sort remaining arguments
%  Sort samples in physical and standard normal space
for n=1:size(Xs.MsamplesHyperCube,2)
	Xs.MsamplesHyperCube(:,n)  = Xs.MsamplesHyperCube(Vindex,n);
end
%  Sort weights
if ~isempty(Xs.Vweights),
    Xs.Vweights = Xs.Vweights(Vindex);
end

%% Output
varargout{1}    = Vsorted;
varargout{2}    = Vindex;

return
