Remarks on optimizer COBYLA

(1) COBYLA is a gradient-free optimization algorithm available for free in 
the internet.
(2) COBYLA is written in C programming language.
(3) A gateway function named cobyla_matlab.c has been developed to 
interface the C original program and Matlab. These codes must be compiled 
in a mex-file in order to be used.

How to produce the compiled mex-file?

In Matlab, type:

mex cobyla_matlab.c cobyla.h cobyla.c

(tested in Matlab2008a running in Debian 4 "Etch")

mex cobyla_matlab.c cobyla.c

(tested in Matlab2008a and Windows Vista)