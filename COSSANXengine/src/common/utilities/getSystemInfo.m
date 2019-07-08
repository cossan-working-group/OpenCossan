function Tinfo = getSystemInfo
%GETSYSTEMINFO Summary of this function goes here
%   Detailed explanation goes here

if isunix
   [~, Sdistribution]=system('lsb_release -i | awk ''{print $3}''');
   [~, Srelease]=system('lsb_release -r | awk ''{print $2}''');
   Tinfo.Srelease=Srelease(1:end-1);
   Tinfo.Sdistribution=Sdistribution(1:end-1);
elseif ismac
    warning('common:utilities:getSystemInfo','Please complete this function for mac OS')
    Tinfo.Sdistribution='It''s a mac';
    Tinfo.Srelease='It''s still a mac';
else
%% SET ENVIROMENT FOR WINDOWS MACHINES        
        Tinfo.Sdistribution='Windows';
        [~,Srelease]=system('ver');
        [Vs]=regexp(Srelease,'\d'); 
        Tinfo.Srelease=Srelease(Vs(1):Vs(end));
end

Tinfo.Smatlabversion=version;
Tinfo.Sarch=getenv('ARCH');

end

