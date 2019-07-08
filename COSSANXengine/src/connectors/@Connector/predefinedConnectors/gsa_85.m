%dedicated connector for OASYS GSA, 32 bit
Xobj.Stype = 'gsa';
Xobj.Ssolverbinary=fullfile('C:','Program Files','Oasys','GSA 8.5','GSA.exe');
Xobj.Sexecmd='%Ssolverbinary %Smaininputfile %Sexeflags';
