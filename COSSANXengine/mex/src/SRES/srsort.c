/*
 * SRSORT Stochastic Ranking Procedure (Stochastic Bubble Sort)
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

#include "mex.h"
#define MAX(A,B) ((A) > (B) ? (A):(B))

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
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
#else
void mexFunction(nlhs, plhs, nrhs, prhs)
int nlhs, nrhs ;
mxArray *plhs[] ;
const mxArray *prhs[] ;
#endif
{
  int n ;
  double *P, *f, *phi ;  
  int i, j ;
  double pf, *I, Is, *G ;

  /* check input arguments */
  if (nrhs != 3)
    mexErrMsgTxt("usage: I = srsort(f,phi,pf) ;") ;

  /* get pointers to input */
  n = mxGetM(prhs[0]) ;
  f = mxGetPr(prhs[0]) ;
  phi = mxGetPr(prhs[1]) ;
  P = mxGetPr(prhs[2]) ;
  pf = P[0] ;

  /* initialize index */
  plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL) ;
  I = mxGetPr(plhs[0]) ;
  for (i=1;i<=n;i++)
    I[i-1] =(double)i ;

  /* allocate random vector */
  if ((G = (double *) mxCalloc(n-1,sizeof(double))) == NULL)
    mexErrMsgTxt("fault: memory allocation error in mxCalloc") ;

  /* perform stochastic bubble sort */
  for (i=0;i<n;i++) {
    Is = 0 ;
    Randomize(G,n-1) ;
    for (j=0;j<(n-1);j++) {
      if (((phi[(int)I[j]-1]==phi[(int)I[j+1]-1]) && (phi[(int)I[j]-1]==0)) || (G[j]<pf) ) {
        if (f[(int)I[j]-1]>f[(int)I[j+1]-1]) {
          Is = I[j] ;
          I[j] = I[j+1] ;
          I[j+1] = Is ;
        }
      }
      else {
        if (phi[(int)I[j]-1]>phi[(int)I[j+1]-1]) { 
          Is = I[j] ;
          I[j] = I[j+1] ;
          I[j+1] = Is ;
        }
      }
    }
    if (Is == 0)
      break ;
  }
  mxFree(G) ;
}
