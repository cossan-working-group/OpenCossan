 /*******************************************************************************
  * bobyqa_matlab: Bound Optimization BY Quadratic Approximation - matlab MEX
  *
  * This is the source code for the MEX use to call bobyqa from matlab. It is 
  * used by the class Bobyqa of OpenCossan 
  *
  * Author: Matteo Broggi, Marco De Angelis
  * Virtual Engineering Centre, University of Liverpool, UK
  * Institute for Risk and Uncertainty, University of Liverpool, UK
  * email address: openengine@cossan.co.uk
  * Website: http://www.cossan.co.uk
  *
  */
  
 /*
  * =====================================================================
  * This file is part of openCOSSAN.  The open general purpose matlab
  * toolbox for numerical analysis, risk and uncertainty quantification.
  *
  * openCOSSAN is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation, either version 3 of the License.
  * 
  * openCOSSAN is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  * 
  * You should have received a copy of the GNU General Public License
  * along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
  * =====================================================================
  */
    
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>
#include <time.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include "include/bobyqa.h"
#include "mex.h"

double calcfc(int n, double *x, void *func_data);

typedef struct
{
    int nprob;
} example_state;

/* 2.   Calling BOBYQA */
void solve_optimization_problem(int n, int npt, double *x, double *xl, 
        double *xu, double *dx, double rhoend, double xtol_rel,
        double minf_max, double ftol_rel, double ftol_abs,
        int maxeval, double *actual_nevals, double *minf,
        int verbose, double *x_opt, double *rc)
{
    example_state state;
    int aux, i, nevals;
    double f;

    aux = bobyqa(n, npt, x, xl, xu, dx,  rhoend, xtol_rel, minf_max,
            ftol_rel, ftol_abs,  maxeval, &nevals, &f, calcfc, NULL,
            NULL, verbose);
    
    *actual_nevals = nevals*1.0;
    *rc            = aux*1.0;
    for(i=0;i<n;i++) {
        *(x_opt+i)  = *(x+i);
    }
}


/* 3. Evaluation of Objective Function and Constraints */
double calcfc(int n, double *x, void *func_data)
{
    int i,check_eval;
    double *x_aux;
    double *f_aux;
    double f;
    mxArray *obj_fun_local[1];
    mxArray *x_local[1];
    
    x_aux       = mxCalloc(n, sizeof(double));
    f_aux       = mxCalloc(1, sizeof(double));
    
    x_local[0]     = mxCreateDoubleMatrix(n,1,mxREAL);
        
    x_aux   = mxGetPr(x_local[0]);
    
    for(i=0;i<n;i++){
        *(x_aux+i)  = *(x+i);
    }
    
    /* Objective Function Evaluation */
    mexPutVariable("caller", "x_eval_bobyqa", x_local[0]);
    check_eval      = mexEvalString("fobj_eval_bobyqa=objective_function_bobyqa(x_eval_bobyqa);");
    if (check_eval){
        mexErrMsgTxt("COSSANX:optimizer:BOBYQA:objective function can not be evaluated");
    }
    obj_fun_local[0]    = mexGetVariable("caller", "fobj_eval_bobyqa");
    f_aux               = mxGetPr(obj_fun_local[0]);
    f=*f_aux;
    
return f;
} /* calcfc */


/* 1.   Gateway Routine */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
            
    double  *x,*x_ini;          //* Initial Solution
    double  *xl, *xu, *dx;      //* Lower bounds, Upper bounds, Step size
    int     maxeval;            //* Maximum number of function evaluations
    int     verbose = 0;        //* verbose=0 => no intermediate information about optimization
    double  rhoend;             //* The required accuracy for the variables
    double  xtol_rel, minf_max,
            ftol_rel, ftol_abs; //* Tolerances
    int     n;                  //* Number of variables
    int     npt;                //* Number of interpolation conditions
    int     i,i1,i2;            //* Auxiliar variables
    double  *nevals;            //* Actual number of function evaluations
    double  *x_opt;             //* Optimal solution
    double  *minf;              //* Optimal value of the objective function
    double  *rc;                //* Return code from bobyqa
    
    if(nrhs != 13){
		mexErrMsgTxt("bobyqa usage: 'values = bobyqa(n,npt,x_ini,xl,xu,dx,rhoend,xtol_rel,minf_max,ftol_rel,ftol_abs,maxeval,verbose)'");
		return;
	}

    
    /* Get the input data */
    /* First Position of the input parameters is not used; it is a "free parameter"*/
    /* Get the Numerical Variables */
    n               = mxGetScalar(prhs[0]);     //* 1. Number of variables
    npt             = mxGetScalar(prhs[1]);     //* 2. Number of interpolation conditions imposed to a quadratic approximation
    x_ini           = mxGetPr(prhs[2]);         //* 3. Initial solution*/
    xl              = mxGetPr(prhs[3]);         //* 4. Lower bounds
    xu              = mxGetPr(prhs[4]);         //* 5. Upper bounds
    dx              = mxGetPr(prhs[5]);         //* 6. Step size computed smaller that the trust region radius
    rhoend          = mxGetScalar(prhs[6]);     //* 7. The required accuracy for the variables*/
    xtol_rel        = mxGetScalar(prhs[7]);     //* 8.
    minf_max        = mxGetScalar(prhs[8]);     //* 9.
    ftol_rel        = mxGetScalar(prhs[9]);     //* 10.
    ftol_abs        = mxGetScalar(prhs[10]);    //* 11.
    maxeval         = mxGetScalar(prhs[11]);    //* 12.
    verbose         = mxGetScalar(prhs[12]);    //* 13.
            
    i1              = mxGetM(prhs[2]);          //*  Get the size of design variable vector*/
    i2              = mxGetN(prhs[2]);          //*  Get the size of design variable vector*/
    
    /*Copy x_ini to x */
    x               = (double *)mxCalloc(n,sizeof(double));
    for(i=0;i<n;i++){
        *(x+i)      = *(x_ini+i);
    }
    
    /* Set the output pointer to the output matrix. */
    plhs[0]         = mxCreateDoubleMatrix(i1, i2, mxREAL);
    plhs[1]         = mxCreateDoubleMatrix(1, 1, mxREAL);
    plhs[2]         = mxCreateDoubleMatrix(1, 1, mxREAL);
    plhs[3]         = mxCreateDoubleMatrix(1, 1, mxREAL);
    
    
    x_opt           = mxGetPr(plhs[0]);
    rc              = mxGetPr(plhs[1]);
    nevals          = mxGetPr(plhs[2]);
    minf            = mxGetPr(plhs[3]);
    
    /* Call Bobyqa */
    solve_optimization_problem(n, npt, x, xl, xu, dx, 
            rhoend, xtol_rel, minf_max, ftol_rel, ftol_abs,
            maxeval, nevals, minf, verbose, x_opt, rc);
}



