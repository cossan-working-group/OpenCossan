function Sfullfile = fullfileunix(varargin)
%FULLFILEUNIX Build full filename from parts for a *nix OS.
%   FULLFILEUNIX(D1,D2, ... ,FILE) builds a full file name from the
%   directories D1,D2, etc and filename FILE specified.  This is
%   conceptually equivalent to
%
%      F = [D1 '/' D2 '/' ... '/' FILE] 
%
%   except that care is taken to handle the cases where the directory
%   parts D1, D2, etc. may begin or end in '/'. 

error(nargchk(1, Inf, nargin));

Sseparator = '/'; 
Sfullfile = varargin{1};

for i=2:nargin,
   Spart = varargin{i};
   if isempty(Sfullfile) || isempty(Spart)
      Sfullfile = [Sfullfile Spart]; %#ok<*AGROW>
   else
      % Handle the three possible cases
      if (Sfullfile(end)==Sseparator) && (Spart(1)==Sseparator),
         Sfullfile = [Sfullfile Spart(2:end)]; 
      elseif (Sfullfile(end)==Sseparator) || (Spart(1)==Sseparator)
         Sfullfile = [Sfullfile Spart];
      else
         Sfullfile = [Sfullfile Sseparator Spart];
      end
   end
end



