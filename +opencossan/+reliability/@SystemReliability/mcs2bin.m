function Cmcs = mcs2bin(Xsys,varargin)
%mcs2bin  Return the binary value of the minimal cut sets
%
%  Usage: Vout=mcs2bin(Xsystem)
%
% =====================================================

if isempty(varargin)
	Sbin=[];																% Reset variable
	for i=1:size(Xsys.Mmcs,2)									   % Cycle over the mcs 
		Sbin=strcat(Sbin,dec2bin(Xsys.Mmcs(:,i)));
	end
else 
	for k=1:2:length(varargin)
	switch lower(varargin{k})
		case ('vmcs')
				Sbin=[];																% Reset variable
			for i=1:size(varargin{k+1},2)									   % Cycle over the mcs 
				Sbin=strcat(Sbin,dec2bin(Xsys.Mmcs(:,i)));
			end
		otherwise
	end
	end
end

% Retun the indexes of the performance function that form the minimal cut-sets. 
for i=1:size(Sbin,1)
	[~, Cmcs{i}]=find(Sbin(i,:)=='1'); %#ok<AGROW>
end
