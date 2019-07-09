function value = mystr2double(Sstring)
% str2double function that convert also string in nastran format

% remove leading and trailing spaces from the string
Sstring=strtrim(Sstring);

% check if the string contains the  'e' of the exponent
indices = strfind(lower(Sstring), 'e');

% if the 'e' is not present (nastran style), insert it immediatly
% before the exponent
signindices = regexp(Sstring, '[+-]'); 

if isempty(indices) 
    % if there is no index of "e", either we are using nastran format or is
    % a fixed point format. The sign will be in position 1 if it is fixed
    % format, or grater than one in nastran format
    if(length(signindices)>1 || (length(signindices)==1 && signindices~=1))
        Sstring = [Sstring(1:signindices(end)-1) 'e' Sstring(signindices(end):end)];
    end
end

value = str2double(Sstring);

end
   