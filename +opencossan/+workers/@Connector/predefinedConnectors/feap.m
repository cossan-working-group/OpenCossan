% dedicated connector for FEAP
% setup the FE parameters for FEAP
Xobj.Stype = 'feap';
Xobj.Ssolverbinary='/usr/software/bin/run_feap.sh';
Xobj.Sexeflags ='';
Xobj.Sexecmd='%Ssolverbinary -i%Smaininputfile -o%Soutputfile';