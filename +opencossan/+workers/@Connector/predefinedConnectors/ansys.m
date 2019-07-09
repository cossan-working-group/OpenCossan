% dedicated connector for ANSYS
Xobj.Stype = 'ansys';
Xobj.Ssolverbinary='/usr/site/ansys/12.0SP1/i386/v120/ansys/bin/ansys120 ';
% -p AA_R is needed to check out license
% -o my_output_file.out is to specify the output file
% > test.out to redirect output to a file (try to avoid it)
% -j my_job_name is the jobname (w/o extension) => is important
% because output files generated accoridngly
% NOTE-HMP: different versions of the licenses are available
%
% -p aa_t_i  : Academic Teaching Introductory (have limits on no of elements)
% -p aa_t_me : Academic Teaching Mechanical (have limits on no of elements)
% -p aa_r    : Academic Research
Xobj.Sexeflags ='-p aa_t_i';
Xobj.Sexecmd='%Ssolverbinary %Sexeflags -i %Smaininputfile  ';