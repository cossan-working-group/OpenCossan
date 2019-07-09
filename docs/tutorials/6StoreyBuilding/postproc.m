% This postprocessing command execute a python script to extract the
% stresses of the columns, stairs, floors and ceiling from the ABAQUS
% outoput database to an ASCII file.
system('/usr/site/bin/abq673 cae noGUI=generate_report.py');