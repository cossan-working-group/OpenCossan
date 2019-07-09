Xobj.Stype = 'nastran';
% dedicated connector for MSC.NASTRAN, 64 bit
Xobj.Ssolverbinary='/Apps/msc/MSC_Nastran/20131/bin/nast20131';
Xobj.Sexeflags ='scr=yes news=no bat=no old=no';
Xobj.Sexecmd='%Ssolverbinary %Smaininputfile %Sexeflags';
Xobj.SerrorFileExtension = 'f06';
Xobj.SerrorString = 'FATAL';