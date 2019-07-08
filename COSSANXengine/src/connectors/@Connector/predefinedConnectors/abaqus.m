% dedicated connector for ABAQUS
Xobj.Stype = 'abaqus';
Xobj.Ssolverbinary='/Apps/abaqus/Commands/abaqus';
if isempty(Xobj.Sexeflags)
    Xobj.Sexeflags ='interactive ask_delete=off';
end

Xobj.Sexecmd='%Ssolverbinary %Sexeflags job=%Smaininputfile ';
Xobj.SerrorFileExtension = 'dat';
Xobj.SerrorString = '***ERROR';