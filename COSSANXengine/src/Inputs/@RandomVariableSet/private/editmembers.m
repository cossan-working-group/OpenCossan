function Xrv = editmembers(Xrv,Sfield,Vnewvalues)
% This is a private function for the rvset class
% It is used to manipulate the rv object embedded on the rvset
%  
% Xrv: array of rv 
% Sfiels: field to be updated
% Vnewvalues: new values of the field
% Update the values of all the members of the rvset 

% Check passed parameters
if length(Vnewvalues)~=length(Xrv)
    error('openCOSSAN:rvset:set',['The vector length of the ' Sfield ' is ' ...
        num2str(length(Vnewvalues)) ' while a vector of ' ...
        num2str(length(Xrv))  ' is required']);
end

for im=1:length(Xrv)
      Xrv{im}=set(Xrv{im},Sfield,Vnewvalues(im));
end

