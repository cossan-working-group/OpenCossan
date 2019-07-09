function Toutput = postFRF( Tinput )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% initialize output structure 
Toutput = cell2struct(cell(length(Tinput),2),{'FRFX','FRFY'},2);

for isample=1:length(Tinput)
    try % successfull FE
        % compute module and angle
        Re = Tinput(isample).FRFX_Re.Vdata; % convert time step to length
        Im = Tinput(isample).FRFX_Im.Vdata;
        FRFX = abs(Re + 1i*Im);
        
        Re = Tinput(isample).FRFY_Re.Vdata; % convert time step to length
        Im = Tinput(isample).FRFY_Im.Vdata;
        FRFY = abs(Re + 1i*Im);
        
        Toutput(isample).FRFX= ...
            Dataseries('Mcoord',Tinput(isample).FRFX_Re.Mcoord,'Vdata',FRFX);
        Toutput(isample).FRFY= ...
            Dataseries('Mcoord',Tinput(isample).FRFY_Re.Mcoord,'Vdata',FRFY);
    catch % failed FE
        Toutput(isample).FRFX = NaN;
        Toutput(isample).FRFY = NaN;
    end
end

end
