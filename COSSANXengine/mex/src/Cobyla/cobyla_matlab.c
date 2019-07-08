/* cobyla : contrained optimization by linear approximation */
/* Example driver */

/*
 * Copyright (c) 1992, Michael J. D. Powell (M.J.D.Powell@damtp.cam.ac.uk)
 * Copyright (c) 2004, Jean-Sebastien Roy (js@jeannot.org)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/*
 * This software is a C version of COBYLA, contrained optimization by linear
 * approximation package originally developed by Michael J. D. Powell in
 * Fortran.
 *
 * The original source code can be found at :
 * http://plato.la.asu.edu/topics/problems/nlores.html
 */

static char const rcsid[] =
"@(#) $Jeannot: example.c,v 1.10 2004/04/17 23:19:15 js Exp $";

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "mex.h"
#include "cobyla.h"

cobyla_function calcfc;

typedef struct
{
    int nprob;
} example_state;

    
/* 2.   Calling Cobyla */
void solve_optimization_problem(double *x, int max_fun_eval, double rhobeg, double rhoend, int n, int m, int iprint, double *actual_fun_eval, double *rc, double *x_opt)
{
    example_state state;
    int aux,i;

    aux = cobyla(n, m, x, rhobeg, rhoend, iprint, &max_fun_eval, calcfc, &state);
    *actual_fun_eval    = max_fun_eval*1.0;
    *rc                 = aux*1.0;
    for(i=0;i<n;i++) {
        *(x_opt+i)  = *(x+i);
    }
}

/* 3. Evaluation of Objective Function and Constraints */
int calcfc(int n, int m, double *x, double *f, double *con, void *state_)
{
    int i,check_eval;
    double *x_aux;
    double *f_aux;
    double *const_aux;
    mxArray *obj_fun_local[1],*constr_local[1];
    mxArray *x_local[1];
    
    x_aux       = mxCalloc(n, sizeof(double));
    f_aux       = mxCalloc(1, sizeof(double));
    const_aux   = mxCalloc(m, sizeof(double));
    
    x_local[0]     = mxCreateDoubleMatrix(n,1,mxREAL);
        
    x_aux   = mxGetPr(x_local[0]);
    
    for(i=0;i<n;i++){
        *(x_aux+i)  = *(x+i);
    }
    
    /* Objective Function Evaluation */
    mexPutVariable("caller", "x_eval_cobyla", x_local[0]);
    check_eval      = mexEvalString("fobj_eval_cobyla=objective_function_cobyla(x_eval_cobyla);");
    if (check_eval){
        mexErrMsgTxt("Objective function can not be evaluated");
    }
    obj_fun_local[0]    = mexGetVariable("caller", "fobj_eval_cobyla");
    f_aux               = mxGetPr(obj_fun_local[0]);
    *f=*f_aux;
    
    /* Objective Function Evaluation */
    check_eval      = mexEvalString("const_eval_cobyla=constraint_cobyla(x_eval_cobyla);");
    if (check_eval){
        mexErrMsgTxt("openCOSSAN:COBYLA:cobyla_matlab:constraint(s) can not be evaluated");
    }
    constr_local[0] = mexGetVariable("caller", "const_eval_cobyla");
    
    if (mxIsEmpty(constr_local[0])==1) {
           *(con+i)    = 0.0;
    }
    else {
        const_aux   = mxGetPr(constr_local[0]);
        for(i=0;i<m;i++){
            *(con+i)    = *(const_aux+i);
        }
    }
    
return 0;
} /* calcfc */


/* 1.   Gateway Routine */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
            
    double  *x,*x_ini;          /*Initial Solution*/
    int     max_fun_eval;       /*Maximum number of function evaluations*/
    int     iprint = 0;         /*iprint=0 => no intermediate information about optimization*/
    double  rhobeg;             /*A reasonable initial change to the variables*/
    double  rhoend;             /*The required accuracy for the variables*/
    int     n;                  /*Number of variables*/
    int     m;                  /*Number of constraints*/
    int     i,i1,i2;            /*Auxiliar variable*/
    double  *rc;                /*Exit flag*/
    double  *actual_fun_eval;   /*Actual number of function evaluations*/
    double  *x_opt;             /*Optimal solution*/
    if(nrhs != 7){
		mexErrMsgTxt("cobyla usage: 'values = cobyla([],x_ini,max_fun_eval,rhobeg, rhoend,n,m)'");
		return;
	}

    
    /* Get the input data */
    /* First Position of the input parameters is not used; it is a "free parameter"*/
    /* Get the Numerical Variables */
    x_ini           = mxGetPr(prhs[1]);         /*Initial solution*/
    max_fun_eval    = mxGetScalar(prhs[2]);     /*Maximum number of function evaluations*/
    rhobeg          = mxGetScalar(prhs[3]);     /*A reasonable initial change to the variables*/
    rhoend          = mxGetScalar(prhs[4]);     /*The required accuracy for the variables*/
    n               = mxGetScalar(prhs[5]);     /*Number of variables*/
    m               = mxGetScalar(prhs[6]);     /*Number of constraints*/
    i1              = mxGetM(prhs[1]);          /*Get the size of design variable vector*/
    i2              = mxGetN(prhs[1]);          /*Get the size of design variable vector*/
    /*Copy x_ini to x */
    x               = (double *)mxCalloc(n,sizeof(double));
    for(i=0;i<n;i++){
        *(x+i)      = *(x_ini+i);
    }
    
    /* Set the output pointer to the output matrix. */
    plhs[0]         = mxCreateDoubleMatrix(i1, i2, mxREAL);
    plhs[1]         = mxCreateDoubleMatrix(1, 1, mxREAL);
    plhs[2]         = mxCreateDoubleMatrix(1, 1, mxREAL);
    
    x_opt           = mxGetPr(plhs[0]);
    rc              = mxGetPr(plhs[1]);
    actual_fun_eval = mxGetPr(plhs[2]);
    
    /* Call Cobyla */
    solve_optimization_problem(x,max_fun_eval,rhobeg,rhoend,n,m,iprint,actual_fun_eval,rc,x_opt);
}















