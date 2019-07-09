/*
 * ARITHX Global Intermediate Recombination
 * Copyright (C) 1998 Thomas Philip Runarsson (e-mail: tpr@verk.hi.is)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 */

#include <math.h>
#include "mex.h"

#ifdef __STDC__
void Randomize (double *D, int N)
#else
void Randomize (D, N)
double *D ;
int N ;
#endif
{
  mxArray *nRand, *Rand[1] ;
  double  *nRandPtr, *RandPtr ;
  int i ;

  nRand = mxCreateDoubleMatrix(1,2,mxREAL) ;
  nRandPtr = mxGetPr(nRand) ;
  nRandPtr[0] = 1 ;
  nRandPtr[1] = (double)N ;
  mexCallMATLAB(1,Rand,1,&nRand,"rand") ;
  RandPtr = mxGetPr(Rand[0]) ;
  for (i=0;i<N;i++)
    D[i] = RandPtr[i] ;
  mxDestroyArray(nRand) ;
  mxDestroyArray(Rand[0]) ;
}


#ifdef __STDC__
void mexFunction(int nlhs,mxArray *plhs[],int nrhs, const mxArray *prhs[])
#else
void mexFunction(nlhs, plhs, nrhs, prhs)
int nlhs, nrhs ;
mxArray *plhs[] ;
const mxArray *prhs[] ;
#endif
{
  int i, j, k, N, n ;
  double *eta_, *eta, *R ;
  double a, b ;

  if (nrhs<1)
    mexErrMsgTxt("usage: eta = arithx(eta);") ;

  N =  mxGetM(prhs[0]) ;
  n =  mxGetN(prhs[0]) ;
  eta_ = mxGetPr(prhs[0]) ;
  plhs[0] = mxCreateDoubleMatrix(N,n,mxREAL) ;
  eta = mxGetPr(plhs[0]) ;

  /* allocate random vector */
  if ((R = (double *) mxCalloc(n*N,sizeof(double))) == NULL)
    mexErrMsgTxt("fault: memory allocation error in mxCalloc") ;

  Randomize(R,n*N) ;
  for (i=0;i<N;i++) {
    for (j=0;j<n;j++) {
      k = (int)(floor(((double)N)*R[j*N+i])) ;
      eta[j*N+i] = (eta_[j*N+i] + eta_[j*N+k])/2.0 ;
    }
  }
  mxFree(R) ;
}
