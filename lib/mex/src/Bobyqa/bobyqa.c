 /*******************************************************************************
 
  Copyright (c) 2012 Turku PET Centre
 
  File: bobyqa.c
  Description: BOBYQA is a derivative-free optimization code with constraints
  by M. J. D. Powell. Original Fortran code by Powell (2009).
 
  Bobyqa seeks the least value of a function of many variables,
  by applying a trust region method that forms quadratic models
  by interpolation. There is usually some freedom in the
  interpolation conditions, which is taken up by minimizing
  the Frobenius norm of the change to the second derivative
  of the model, beginning with the zero matrix. The values of
  the variables are constrained by upper and lower bounds.
 
  This implements the method with a few modifications to make it
  easier to use at Turku PET Centre.
 
  If you are interested to use BOBYQA outside Turku PET Centre,
  we would strongly uggest using other libraries instead;
  for example http://dlib.net/ and http://ab-initio.mit.edu/nlopt/.
 
  This program is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free Software
  Foundation; either version 2 of the License, or (at your option) any later
  version.
 
  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 
  You should have received a copy of the GNU General Public License along with
  this program; if not, write to the Free Software Foundation, Inc., 59 Temple
  Place, Suite 330, Boston, MA 02111-1307 USA.
 
  Turku PET Centre hereby disclaims all copyright interest in the program.
  Juhani Knuuti
  Director, Professor
  Turku PET Centre, Turku, Finland, http://www.turkupetcentre.fi/
 
  Modification history:
  2012-09-05 Vesa Oikonen
  First created.
  2012-09-07 VO
  bobyqb() returns BOBYQA_RELFTOL_REACHED or BOBYQA_ABSFTOL_REACHED
  instead of BOBYQA_FTOL_REACHED, when appropriate.
  Function bobyqa_rc() supports new bobyqa_result enums BOBYQA_FAIL,
  BOBYQA_RELFTOL_REACHED, and BOBYQA_ABSFTOL_REACHED.
  2012-09-12 VO
  bobyqb_xupdate(): copied x[] are scaled back, and always sets bdata->minf.
  bobyqa_set_optimization(): previously rhobeg was always 1, but now it may
  be set to <1 if scaled parameter limits would otherwise be too tight.
  2012-09-17 VO
  Added isfinite() tests.
  Applied fma() in a few suitable places.
  Verbose value checked before printing in stdout.
 
 
 *******************************************************************************/
 #include <stdio.h>
 #include <stdlib.h>
 #include <math.h>
 #include <string.h>
 /******************************************************************************/
 #include "include/bobyqa.h"
 /******************************************************************************/
 
 /******************************************************************************/
 /* Local function definitions */
 extern void bobyqa_update(bobyqa_data *bdata);
 extern bobyqa_result bobyqa_rescue(bobyqa_data *bdata);
 extern void bobyqa_altmov(bobyqa_data *bdata);
 extern void bobyqa_trsbox(bobyqa_data *bdata);
 extern bobyqa_result bobyqa_prelim(bobyqa_data *bdata);
 /******************************************************************************/
 
 /******************************************************************************/
 bobyqa_result bobyqa(
  int n,
  int npt,
  double *x,
  const double *xl,
  const double *xu,
  const double *dx,
  const double rhoend,
  double xtol_rel,
  double minf_max,
  double ftol_rel,
  double ftol_abs,
  int maxeval,
  int *nevals,
  double *minf,
  double (*f)(int n, double *x, void *objf_data),
  void *objf_data,
  double *working_space,
  int verbose
 ) {
  int i, j;
  int fixed_n, fitted_n;
  bobyqa_data bdata;
  bobyqa_result ret;
 
 
  if(verbose>0) printf("in bobyqa()\n");
  if(verbose>4) {
  printf("original dx={%g", dx[0]);
  for(j=1; j<n; j++) printf(", %g", dx[j]); printf("}\n");
  }
 
  /* Check if any of parameters is fixed:
  Only free parameters are given to Bobyqa for fitting, therefore
  the number is needed in allocating and setting up memory.
  BOBYQA requires that at least two parameters are fitted, but later
  a simple 1-D method is used instead when necessary */
  fixed_n=fixed_params(n, xl, xu, dx);
  fitted_n=n-fixed_n;
  if(verbose>1) {
  printf("%d parameter(s) are fixed.\n", fixed_n); fflush(stdout);
  }
  if(fitted_n<1) {
  if(verbose>0) fprintf(stderr, "Error: no free parameters.\n");
  return BOBYQA_INVALID_ARGS;
  }
  if(fitted_n==1 && verbose>0)
  fprintf(stderr, "Warning: only one free parameter.\n");
 
  /* Set npt, if user did not do that */
  if(npt<=0) npt=2*fitted_n+1;
  /* Verify that NPT is in the required interval */
  if(npt<fitted_n+2 || npt>(fitted_n+2)*(fitted_n+1)/2) {
  if(verbose>0) {
  printf("npt:=%d\n", npt);
  fprintf(stderr, "Error: bad npt.\n");
  }
  return(BOBYQA_INVALID_ARGS);
  }
 
  /* Allocate double working_space, if not done by caller */
  i=bobyqa_working_memory_size(n, fitted_n, npt, &bdata);
  ret=bobyqa_set_memory(n, fitted_n, npt, &bdata, working_space);
  if(ret!=BOBYQA_SUCCESS) return(BOBYQA_OUT_OF_MEMORY);
 
  /* Copy BOBYQA parameters to bdata struct */
  ret=bobyqa_set_optimization(n, x, dx, xl, xu, rhoend, xtol_rel,
  minf_max, ftol_rel, ftol_abs, maxeval,
  f, objf_data, verbose, &bdata);
  if(ret!=BOBYQA_SUCCESS) {
  bobyqa_free_memory(&bdata); return(BOBYQA_INVALID_ARGS);
  }
  if(verbose>2) bobyqa_print(&bdata, 4, stdout);
 
 
  /* Call BOBYQB */
  if(bdata.n>1) { // BOBYQA works only if at least 2 parameters are fitted
  ret = bobyqb(&bdata);
  if(bdata.verbose>1) printf("ret := %d\n", ret);
  if(bdata.verbose>0) {
  if(ret<0) printf("Error in bobyqb(): %s\n", bobyqa_rc(ret));
  else printf("Return code of bobyqb(): %s\n", bobyqa_rc(ret));
  }
  } else { // Simple local 1-D minimization when necessary
  ret=bobyqa_minimize_single_parameter(&bdata);
  if(bdata.verbose>1) printf("ret := %d\n", ret);
  if(bdata.verbose>0 && ret<0)
  printf("Error %d in 1-D optimization\n", ret);
  }
  /* Copy fitted parameters to full parameter list */
  bobyqa_xfull(&bdata);
  for(i=0; i<n; i++) x[i]=bdata.xfull[i];
  if(nevals!=NULL) *nevals=bdata.nevals;
  /* Copy min value to argument pointer */
  *minf=bdata.minf;
 
  /* Quit */
  if(verbose>1) {
  printf("prelim() called %d time(s)\n", bdata.prelim_nr);
  printf("rescue() called %d time(s)\n", bdata.rescue_nr);
  printf("altmov() called %d time(s)\n", bdata.altmov_nr);
  printf("trsbox() called %d time(s)\n", bdata.trsbox_nr);
  printf("update() called %d time(s)\n", bdata.update_nr);
  }
  bobyqa_free_memory(&bdata);
 
  if(verbose>0) printf("out of bobyqa() with return code %d\n", ret);
  return ret;
 } /* bobyqa() */
 /*****************************************************************************/
 
 /*****************************************************************************/
 int bobyqa_minimize_single_parameter(
  bobyqa_data *bdata
 ) {
  if(bdata->verbose>0) {
  printf("bobyqa_minimize_single_parameter()\n"); fflush(stdout);}
 
  double p1=0, p2=0, p3=0, f1=0, f2=0, f3=0, begin, end;
  double d, d2, jump_size;
  const double tau=0.1;
  double p_min, f_min, bracket_ratio;
 
  /* Check the input */
  if(bdata->n!=1) return BOBYQA_INVALID_ARGS;
  if(bdata->rhoend<=0.0) return BOBYQA_INVALID_ARGS;
  if(bdata->rhoend>=bdata->rhobeg) return BOBYQA_INVALID_ARGS;
  if(bdata->maxeval<2) return BOBYQA_INVALID_ARGS;
 
  begin=bdata->xl[0];
  end=bdata->xu[0];
 
  /* Update the full parameter list for objf() */
  bdata->nevals=0;
  f2 = bdata->minf = bobyqa_x_funcval(bdata, bdata->x);
  /* If parameter is fixed, then this was all that we can do */
  if(bdata->xl[0]>=bdata->xu[0]) {
  if(bdata->verbose>1) printf("Warning: the only parameter is fixed\n");
  return BOBYQA_SUCCESS;
  }
 
  /* Find three bracketing points such that f1 > f2 < f3.
  Do this by generating a sequence of points expanding away from 0.
  Also note that, in the following code, it is always the
  case that p1 < p2 < p3. */
  p2=bdata->x[0];
 
  /* Start by setting a starting set of 3 points that are inside the bounds */
  p1=p2-1.0; if(p1>begin) p1=begin;
  p3=p2+1.0; if(p3<end) p3=end;
  /* Compute their function values */
  bdata->x[0]=p1;
  f1 = bdata->minf = bobyqa_x_funcval(bdata, bdata->x);
  bdata->x[0]=p3;
 
  f3 = bdata->minf = bobyqa_x_funcval(bdata, bdata->x);
 
  if(p2==p1 || p2==p3) {
  p2=0.5*(p1+p3);
  bdata->x[0]=p2;
  f2 = bdata->minf = bobyqa_x_funcval(bdata, bdata->x);
  }
 
  /* Now we have 3 points on the function.
  Start looking for a bracketing set such that f1 > f2 < f3 is the case. */
  jump_size=1.0;
  while(!(f1>f2 && f2<f3)) {
  /* check for hitting max_iter */
  if(bdata->verbose>5) printf(" bracketing: nevals=%d\n", bdata->nevals);
  if(bdata->nevals >= bdata->maxeval) {
  bdata->x[0]=p2; bdata->minf=f2; return BOBYQA_MAXEVAL_REACHED;
  }
  /* check if required tolerance was reached */
  if((p3-p1)<bdata->rhoend) { //if (p3-p1 < eps)
  if(bdata->verbose>1)
  printf(" max tolerance was reached during bracketing\n");
  if(f1<f2 && f1<f3) {
  bdata->x[0]=p1; bdata->minf=f1; return BOBYQA_XTOL_REACHED;
  }
  if(f2<f1 && f2<f3) {
  bdata->x[0]=p2; bdata->minf=f2; return BOBYQA_XTOL_REACHED;
  }
  bdata->x[0]=p3; bdata->minf=f3; return BOBYQA_XTOL_REACHED;
  }
  if(bdata->verbose>6) printf(" jump_size=%g\n", jump_size);
  /* if f1 is small then take a step to the left */
  if(f1<f3) {
  /* check if the minimum is colliding against the bounds. If so then pick
  a point between p1 and p2 in the hopes that shrinking the interval will
  be a good thing to do. Or if p1 and p2 aren't differentiated then try
  and get them to obtain different values. */
  if(p1==begin || (f1==f2 && (end-begin)<jump_size )) {
  p3=p2; f3=f2; p2=0.5*(p1+p2);
  bdata->x[0]=p2;
  f2 = bdata->minf = bobyqa_x_funcval(bdata, bdata->x);
  } else {
  /* pick a new point to the left of our current bracket */
  p3=p2; f3=f2; p2=p1; f2=f1;
  p1-=jump_size; if(p1<begin) p1=begin;
  bdata->x[0]=p1;
  f1 = bobyqa_x_funcval(bdata, bdata->x);
  jump_size*=2.0;
  }
  } else { // otherwise f3 is small and we should take a step to the right
  /* check if the minimum is colliding against the bounds. If so then pick
  a point between p2 and p3 in the hopes that shrinking the interval will
  be a good thing to do. Or if p2 and p3 aren't differentiated then
  try and get them to obtain different values. */
  if(p3==end || (f2==f3 && (end-begin)<jump_size)) {
  p1=p2; f1=f2; p2=0.5*(p3+p2);
  bdata->x[0]=p2;
  f2 = bdata->minf = bobyqa_x_funcval(bdata, bdata->x);
  } else {
  /* pick a new point to the right of our current bracket */
  p1=p2; f1=f2; p2=p3; f2=f3;
  p3+=jump_size; if(p3>end) p3=end;
  bdata->x[0]=p3;
  f3 = bdata->minf = bobyqa_x_funcval(bdata, bdata->x);
  jump_size*=2.0;
  }
  }
  }
  if(bdata->verbose>4) printf(" brackets ready\n");
 
  /* Loop until we have done the max allowable number of iterations or
  the bracketing window is smaller than eps.
  Within this loop we maintain the invariant that: f1 > f2 < f3 and
  p1 < p2 < p3. */
  while((bdata->nevals<bdata->maxeval) && (p3-p1>bdata->rhoend)) {
  if(bdata->verbose>5) printf(" main loop: nevals=%d\n", bdata->nevals);
 
  //p_min = lagrange_poly_min_extrap(p1,p2,p3, f1,f2,f3);
  d=f1*(p3*p3-p2*p2) + f2*(p1*p1-p3*p3) + f3*(p2*p2-p1*p1);
  d2=2.0*(f1*(p3-p2) + f2*(p1-p3) + f3*(p2-p1));
  if(d2==0.0 || !isfinite(d/=d2)) { // d=d/d2
  p_min=p2;
  } else {
  if(p1<=d && d<=p3) {p_min=d;}
  else {p_min=d; if(p1>p_min) p_min=p1; if(p3<p_min) p_min=p3;}
  }
 
  /* make sure p_min isn't too close to the three points we already have */
  if(p_min<p2) {
  d=(p2-p1)*tau;
  if(fabs(p1-p_min)<d) p_min=p1+d;
  else if(fabs(p2-p_min)<d) p_min=p2-d;
  } else {
  d=(p3-p2)*tau;
  if(fabs(p2-p_min)<d) p_min=p2+d;
  else if(fabs(p3-p_min)<d) p_min=p3-d;
  }
 
  /* make sure one side of the bracket isn't super huge compared to the other
  side. If it is then contract it. */
  bracket_ratio=fabs(p1-p2)/fabs(p2-p3);
  if(!(bracket_ratio<100.0 && bracket_ratio>0.01)) {
  /* Force p_min to be on a reasonable side. But only if
  lagrange_poly_min_extrap() didn't put it on a good side already. */
  if(bracket_ratio>1.0 && p_min>p2) p_min=0.5*(p1+p2);
  else if(p_min<p2) p_min=0.5*(p2+p3);
  }
 
  /* Compute function value at p_min */
  bdata->x[0]=p_min;
  f_min = bdata->minf = bobyqa_x_funcval(bdata, bdata->x);
 
  /* Remove one of the endpoints of our bracket depending on where
  the new point falls */
  if(p_min<p2) {
  if(f1>f_min && f_min<f2) {p3=p2; f3=f2; p2=p_min; f2=f_min;}
  else {p1=p_min; f1 = f_min;}
  } else {
  if(f2>f_min && f_min<f3) {p1=p2; f1=f2; p2=p_min; f2=f_min;}
  else {p3=p_min; f3=f_min;}
  }
  }
  bdata->x[0]=p2; bdata->minf=f2;
  if(bdata->nevals>=bdata->maxeval) return BOBYQA_MAXEVAL_REACHED;
  return BOBYQA_XTOL_REACHED;
 }
 /*****************************************************************************/
 
 /*****************************************************************************/
 char *bobyqa_rc(
  bobyqa_result rc
 ) {
  static char *bobyqa_msg[] = {
  /* 0 */ "failure",
  /* 1 */ "invalid argument",
  /* 2 */ "out of memory",
  /* 3 */ "round-off limited",
  /* 4 */ "success",
  /* 5 */ "requested function value reached",
  /* 6 */ "function value tolerance reached",
  /* 7 */ "relative function value tolerance reached",
  /* 8 */ "absolute function value tolerance reached",
  /* 9 */ "parameter tolerance reached",
  /* 10 */ "maximum number of function evaluations reached",
  0};
  switch(rc) {
  case BOBYQA_FAIL: return bobyqa_msg[0];
  case BOBYQA_INVALID_ARGS: return bobyqa_msg[1];
  case BOBYQA_OUT_OF_MEMORY: return bobyqa_msg[2];
  case BOBYQA_ROUNDOFF_LIMITED: return bobyqa_msg[3];
  case BOBYQA_SUCCESS: return bobyqa_msg[4];
  case BOBYQA_MINF_MAX_REACHED: return bobyqa_msg[5];
  case BOBYQA_FTOL_REACHED: return bobyqa_msg[6];
  case BOBYQA_RELFTOL_REACHED: return bobyqa_msg[7];
  case BOBYQA_ABSFTOL_REACHED: return bobyqa_msg[8];
  case BOBYQA_XTOL_REACHED: return bobyqa_msg[9];
  case BOBYQA_MAXEVAL_REACHED: return bobyqa_msg[10];
  }
  return bobyqa_msg[0];
 }
 /*****************************************************************************/
 
 /*****************************************************************************/
 int fixed_params(
  int n,
  const double *lower,
  const double *upper,
  const double *delta
 ) {
  int i, fixed_n=0;
  for(i=0; i<n; i++) {
  if(upper[i]<=lower[i]) {fixed_n++; continue;}
  if(delta!=NULL && delta[i]==0.0) fixed_n++;
  }
  return(fixed_n);
 }
 /*****************************************************************************/
 
 /*****************************************************************************/
 int bobyqa_working_memory_size(
  int n,
  int fitted_n,
  int npt,
  bobyqa_data *bdata
 ) {
  int i=0, s, np, ndim;
 
  np=fitted_n+1; ndim=npt+fitted_n;
 
  s=n; i+=s; if(bdata!=NULL) bdata->nfull=s;
 
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->x_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->xl_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->xu_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->xbase_size=s;
  s=fitted_n*npt; i+=s; if(bdata!=NULL) bdata->xpt_size=s;
  s=npt; i+=s; if(bdata!=NULL) bdata->fval_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->xopt_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->gopt_size=s;
  s=fitted_n*np/2; i+=s; if(bdata!=NULL) bdata->hq_size=s;
  s=npt; i+=s; if(bdata!=NULL) bdata->pq_size=s;
  s=ndim*fitted_n; i+=s; if(bdata!=NULL) bdata->bmat_size=s;
  s=npt*(npt-np); i+=s; if(bdata!=NULL) bdata->zmat_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->sl_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->su_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->xnew_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->xalt_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->dtrial_size=s;
  s=ndim; i+=s; if(bdata!=NULL) bdata->vlag_size=s;
 
  s=2*npt; i+=s; if(bdata!=NULL) bdata->w2npt_size=s;
  s=ndim; i+=s; if(bdata!=NULL) bdata->wndim_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->wn_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->gnew_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->xbdi_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->s_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->hs_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->hred_size=s;
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->glag_size=s;
  s=npt; i+=s; if(bdata!=NULL) bdata->hcol_size=s;
  s=2*fitted_n; i+=s; if(bdata!=NULL) bdata->ccstep_size=s;
 
  s=fitted_n; i+=s; if(bdata!=NULL) bdata->xscale_size=s;
 
  //bobyqa_print(bdata, 2, stdout);
  return(i);
 }
 /*****************************************************************************/
 
 /*****************************************************************************/
 bobyqa_result bobyqa_set_memory(
  int n,
  int fitted_n,
  int npt,
  bobyqa_data *bdata,
  double *wm
 ) {
  int wmsize;
  double *lwm, *wptr;
  int *liwm;
 
  if(n<1 || fitted_n<1 || npt<1 || bdata==NULL) return BOBYQA_INVALID_ARGS;
 
  /* Determine the required size of working memory and set the sizes
  inside data struct */
  wmsize=bobyqa_working_memory_size(n, fitted_n, npt, bdata);
 
  /* If working memory for doubles is not preallocated, then allocate it */
  if(wm!=NULL) {
  lwm=wm; bdata->lwmptr=NULL;
  } else {
  /* Allocate working memory */
  lwm=(double*)malloc(sizeof(double)*wmsize);
  if(lwm==NULL) {
  return(BOBYQA_OUT_OF_MEMORY);
  }
  bdata->lwmptr=lwm;
  }
  bdata->wmptr=lwm;
 
  /* Working memory for integers is always allocated here */
  liwm=(int*)malloc(sizeof(int)*fitted_n);
  if(liwm==NULL) {
  if(wm==NULL) bobyqa_free_memory(bdata);
  return(BOBYQA_OUT_OF_MEMORY);
  }
  bdata->liwmptr=liwm;
 
  /* Set data pointers inside bobyqa struct */
  bdata->xplace=bdata->liwmptr;
  wptr=bdata->wmptr;
  bdata->xfull=wptr; wptr+=bdata->nfull;
  bdata->x=wptr; wptr+=bdata->x_size;
  bdata->xl=wptr; wptr+=bdata->xl_size;
  bdata->xu=wptr; wptr+=bdata->xu_size;
  bdata->xbase=wptr; wptr+=bdata->xbase_size;
  bdata->xpt=wptr; wptr+=bdata->xpt_size;
  bdata->fval=wptr; wptr+=bdata->fval_size;
  bdata->xopt=wptr; wptr+=bdata->xopt_size;
  bdata->gopt=wptr; wptr+=bdata->gopt_size;
  bdata->hq=wptr; wptr+=bdata->hq_size;
  bdata->pq=wptr; wptr+=bdata->pq_size;
  bdata->bmat=wptr; wptr+=bdata->bmat_size;
  bdata->zmat=wptr; wptr+=bdata->zmat_size;
  bdata->sl=wptr; wptr+=bdata->sl_size;
  bdata->su=wptr; wptr+=bdata->su_size;
  bdata->xnew=wptr; wptr+=bdata->xnew_size;
  bdata->xalt=wptr; wptr+=bdata->xalt_size;
  bdata->dtrial=wptr; wptr+=bdata->dtrial_size;
  bdata->vlag=wptr; wptr+=bdata->vlag_size;
  bdata->w2npt=wptr; wptr+=bdata->w2npt_size;
  bdata->wndim=wptr; wptr+=bdata->wndim_size;
  bdata->wn=wptr; wptr+=bdata->wn_size;
  bdata->gnew=wptr; wptr+=bdata->gnew_size;
  bdata->xbdi=wptr; wptr+=bdata->xbdi_size;
  bdata->s=wptr; wptr+=bdata->s_size;
  bdata->hs=wptr; wptr+=bdata->hs_size;
  bdata->hred=wptr; wptr+=bdata->hred_size;
  bdata->glag=wptr; wptr+=bdata->glag_size;
  bdata->hcol=wptr; wptr+=bdata->hcol_size;
  bdata->ccstep=wptr; wptr+=bdata->ccstep_size;
  bdata->xscale=wptr; wptr+=bdata->xscale_size;
 
  /* Set struct contents */
  bdata->n=fitted_n;
  bdata->nfull=n;
  bdata->npt=npt;
  bdata->ndim = npt+fitted_n;
  if(bobyqa_reset_memory(bdata)!=BOBYQA_SUCCESS) return BOBYQA_INVALID_ARGS;
 
  return BOBYQA_SUCCESS;
 }
 /*****************************************************************************/
 bobyqa_result bobyqa_free_memory(
  bobyqa_data *bdata
 ) {
  if(bdata==NULL) return BOBYQA_INVALID_ARGS;
  /* Free double working memory, if it was allocated by bobyqa_set_memory() */
  if(bdata->lwmptr!=NULL) free(bdata->lwmptr);
  bdata->lwmptr=NULL;
  /* Free integer working memory */
  if(bdata->liwmptr!=NULL) free(bdata->liwmptr);
  bdata->liwmptr=NULL;
  return BOBYQA_SUCCESS;
 }
 /*****************************************************************************/
 
 /*****************************************************************************/
 bobyqa_result bobyqa_reset_memory(
  bobyqa_data *bdata
 ) {
 
  if(bdata==NULL) return BOBYQA_INVALID_ARGS;
  if(bdata->npt<1 || bdata->n<1) return BOBYQA_INVALID_ARGS;
 
  /* Initiate struct variables */
  bdata->dsq=0.0;
  bdata->xoptsq=0.0;
  bdata->rc = BOBYQA_SUCCESS;
  bdata->knew = 0;
  bdata->scaden = 0.0;
  bdata->biglsq = 0.0;
  bdata->nptm = bdata->npt - (bdata->n+1);
  bdata->nevals=0;
  bdata->rescue_nr=bdata->altmov_nr=bdata->trsbox_nr=bdata->update_nr=0;
  bdata->prelim_nr=0;
 
  return BOBYQA_SUCCESS;
 }
 /*****************************************************************************/
 
 /*****************************************************************************/
 void bobyqa_print(
  bobyqa_data *bdata,
  int sw,
  FILE *fp
 ) {
  int i;
 
  if(bdata==NULL) {
  fprintf(fp, "bobyqa data struct not defined.\n");
  return;
  }
 
  if(sw==0 || sw==1) {
  fprintf(fp, "nfull=%d\n", bdata->nfull);
  fprintf(fp, "n=%d\n", bdata->n);
  fprintf(fp, "npt=%d\n", bdata->npt);
  fprintf(fp, "ndim=%d\n", bdata->ndim);
  }
 
  if(sw==0 || sw==2) {
  fprintf(fp, "nfull=%d\n", bdata->nfull);
  fprintf(fp, "x_size=%d\n", bdata->x_size);
  fprintf(fp, "xl_size=%d\n", bdata->xl_size);
  fprintf(fp, "xu_size=%d\n", bdata->xu_size);
  fprintf(fp, "xbase_size=%d\n", bdata->xbase_size);
  fprintf(fp, "xpt_size=%d\n", bdata->xpt_size);
  fprintf(fp, "fval_size=%d\n", bdata->fval_size);
  fprintf(fp, "xopt_size=%d\n", bdata->xopt_size);
  fprintf(fp, "gopt_size=%d\n", bdata->gopt_size);
  fprintf(fp, "hq_size=%d\n", bdata->hq_size);
  fprintf(fp, "pq_size=%d\n", bdata->pq_size);
  fprintf(fp, "bmat_size=%d\n", bdata->bmat_size);
  fprintf(fp, "zmat_size=%d\n", bdata->zmat_size);
  fprintf(fp, "sl_size=%d\n", bdata->sl_size);
  fprintf(fp, "su_size=%d\n", bdata->su_size);
  fprintf(fp, "xnew_size=%d\n", bdata->xnew_size);
  fprintf(fp, "xalt_size=%d\n", bdata->xalt_size);
  fprintf(fp, "dtrial_size=%d\n", bdata->dtrial_size);
  fprintf(fp, "vlag_size=%d\n", bdata->vlag_size);
  fprintf(fp, "w2npt_size=%d\n", bdata->w2npt_size);
  fprintf(fp, "wndim_size=%d\n", bdata->wndim_size);
  fprintf(fp, "wn_size=%d\n", bdata->wn_size);
  fprintf(fp, "gnew_size=%d\n", bdata->gnew_size);
  fprintf(fp, "xbdi_size=%d\n", bdata->xbdi_size);
  fprintf(fp, "s_size=%d\n", bdata->s_size);
  fprintf(fp, "hs_size=%d\n", bdata->hs_size);
  fprintf(fp, "hred_size=%d\n", bdata->hred_size);
  fprintf(fp, "glag_size=%d\n", bdata->hred_size);
  fprintf(fp, "hcol_size=%d\n", bdata->hcol_size);
  fprintf(fp, "ccstep_size=%d\n", bdata->ccstep_size);
  fprintf(fp, "xscale_size=%d\n", bdata->xscale_size);
  }
 
  if(sw==0 || sw==3) {
  fprintf(fp, "full parameter list:\n");
  for(i=0; i<bdata->nfull; i++) {
  fprintf(fp, " xfull[%d] = %g\n", i, bdata->xfull[i]);
  }
  }
 
  if(sw==0 || sw==4) {
  fprintf(fp, "fitted parameter indices =");
  for(i=0; i<bdata->n; i++) {
  fprintf(fp, " xplace[%d] = %d\n", i, bdata->xplace[i]);
  }
  fprintf(fp, "fitted parameter list:\n");
  for(i=0; i<bdata->n; i++) {
  fprintf(fp, " x[%d] = %g\n", i, bdata->x[i]);
  }
  fprintf(fp, "lower limits:\n");
  for(i=0; i<bdata->n; i++) {
  fprintf(fp, " xl[%d] = %g\n", i, bdata->xl[i]);
  }
  fprintf(fp, "upper limits:\n");
  for(i=0; i<bdata->n; i++) {
  fprintf(fp, " xu[%d] = %g\n", i, bdata->xu[i]);
  }
  fprintf(fp, "rescaling factors:\n");
  for(i=0; i<bdata->n; i++) {
  fprintf(fp, " xscale[%d] = %g\n", i, bdata->xscale[i]);
  }
  fprintf(fp, "rhobeg=%g\n", bdata->rhobeg);
  fprintf(fp, "rhoend=%g\n", bdata->rhoend);
 
  fprintf(fp, "scaled lower bounds:\n");
  for(i=0; i<bdata->n; i++) {
  fprintf(fp, " sl[%d] = %g\n", i, bdata->sl[i]);
  }
  fprintf(fp, "scaled upper bounds:\n");
  for(i=0; i<bdata->n; i++) {
  fprintf(fp, " su[%d] = %g\n", i, bdata->su[i]);
  }
  }
 
  return;
 }
 /*****************************************************************************/
 
 /*****************************************************************************/
 double bobyqa_x_funcval(
  bobyqa_data *bdata,
  double *x
 ) {
  int j;
  double v;
 
  for(j=0; j<bdata->n; j++) bdata->xfull[bdata->xplace[j]]=x[j]*bdata->xscale[j];
  v = bdata->objf(bdata->nfull, bdata->xfull, bdata->objf_data);
  bdata->nevals++;
  return(v);
 }
 /******************************************************************************/
 
 /******************************************************************************/
 void bobyqa_xfull(
  bobyqa_data *bdata
 ) {
  int j;
  for(j=0; j<bdata->n; j++)
  bdata->xfull[bdata->xplace[j]]=bdata->x[j]*bdata->xscale[j];
 }
 /******************************************************************************/
 
 /******************************************************************************/
 bobyqa_result bobyqa_set_optimization(
  int full_n,
  double *x,
  const double *dx,
  const double *xl,
  const double *xu,
  const double rhoend,
  double xtol_rel,
  double minf_max,
  double ftol_rel,
  double ftol_abs,
  int maxeval,
  double (*f)(int n, double *x, void *objf_data),
  void *objf_data,
  int verbose,
  bobyqa_data *bdata
 ) {
  int i, j;
  double d, dm;
 
  if(bdata==NULL) return BOBYQA_INVALID_ARGS;
  if(full_n!=bdata->nfull) return BOBYQA_INVALID_ARGS;
  if(x==NULL || dx==NULL) return BOBYQA_INVALID_ARGS;
  if(xl==NULL || xu==NULL) return BOBYQA_INVALID_ARGS;
 
  /* Copy full parameter list */
  for(i=0; i<full_n; i++) bdata->xfull[i]=x[i];
 
  /* Make list of fitted parameters (those that are not fixed);
  and internal list of their positions in full list;
  and rescaling factor for each dimension based on initial step size
  so that initial step size would be equal in all directions
  */
  for(i=j=0; i<full_n; i++) if(dx[i]!=0.0 && xu[i]>xl[i]) {
  /* Positions in full list */
  bdata->xplace[j]=i;
  /* Set scaling factors */
  bdata->xscale[j]=fabs(dx[i]);
  /* Set initial scaled parameters */
  bdata->x[j]=x[i]/bdata->xscale[j];
  /* Set scaled limits */
  bdata->xl[j]=xl[i]/bdata->xscale[j];
  bdata->xu[j]=xu[i]/bdata->xscale[j];
  j++; // index of fitted parameters
  } // next parameter
  /* check that nr of fitted parameters is the same that was used to
  allocate memory in the data struct */
  if(j!=bdata->n) return BOBYQA_INVALID_ARGS;
 
  /* Initial step sizes are now internally scaled to 1, therefore: */
  bdata->rhobeg = 1.0;
  /* however, 2*rhobeg must be <= xu[]-xl[] */
  j=0; dm=bdata->xu[j]-bdata->xl[j];
  for(j=1; j<bdata->n; j++) {d=bdata->xu[j]-bdata->xl[j]; if(d<dm) dm=d;}
  if(dm < 2.*bdata->rhobeg) {
  if(dm>1.0E-20) {
  /* Set smaller rhobeg to have sufficient space between the bounds */
  bdata->rhobeg=0.5*dm;
  } else {
  /* Return from BOBYQA because one of the differences
  XU(I)-XL(I)s is less than 2*RHOBEG, and very small, too. */
  if(verbose>0) fprintf(stderr, "Error: stepsize<2*rhobeg\n");
  printf("smallest stepsize=%g 2*rhobeg=%g\n", dm, 2.*bdata->rhobeg);
  return(BOBYQA_INVALID_ARGS);
  }
  }
 
  /* Set rhoend; if not given by caller, then compute rhoend from
  optimization stop info */
  if(rhoend>0.0) bdata->rhoend=rhoend;
  else bdata->rhoend = xtol_rel * bdata->rhobeg;
  if(!isfinite(bdata->rhoend)) bdata->rhoend=1.0E-14;
 
  /* Return error if there is insufficient space between the bounds.
  Modify the initial estimates X[], if necessary, in order to avoid
  conflicts between the bounds and the construction of the first quadratic
  model.
  The lower and upper bounds (sl[], su[]) on moves from the updated X[]
  are set now, in order to provide useful and exact information about
  components of X[] that become within distance RHOBEG from their bounds. */
  for(j=0; j<bdata->n; j++) {
  d=bdata->xu[j]-bdata->xl[j];
  /* Set sl and su */
  bdata->sl[j]= bdata->xl[j]-bdata->x[j];
  bdata->su[j] = bdata->xu[j]-bdata->x[j];
  if(bdata->sl[j] >= -bdata->rhobeg) {
  if(bdata->sl[j] >= 0.0) {
  bdata->x[j]=bdata->xl[j];
  bdata->sl[j]=0.0;
  bdata->su[j]=d;
  } else {
  bdata->x[j]=bdata->xl[j]+bdata->rhobeg;
  bdata->sl[j]=-bdata->rhobeg;
  bdata->su[j]=fmax(bdata->xu[j]-bdata->x[j], bdata->rhobeg);
  }
  } else if(bdata->su[j] <= bdata->rhobeg) {
  if(bdata->su[j] <= 0.0) {
  bdata->x[j]=bdata->xu[j];
  bdata->sl[j]=-d;
  bdata->su[j]=0.0;
  } else {
  bdata->x[j]=bdata->xu[j]-bdata->rhobeg;
  bdata->sl[j]=fmin(bdata->xl[j]-bdata->x[j], -bdata->rhobeg);
  bdata->su[j]=bdata->rhobeg;
  }
  }
  }
 
  bdata->verbose=verbose;
  bdata->minf_max=minf_max;
  bdata->ftol_rel=ftol_rel;
  bdata->ftol_abs=ftol_abs;
  bdata->maxeval=maxeval;
 
  bdata->objf=(bobyqa_func)f;
  bdata->objf_data=objf_data;
 
  return BOBYQA_SUCCESS;
 }
 /*****************************************************************************/
 
 /*****************************************************************************/
 // BOBYQB
 void bobyqb_xupdate(bobyqa_data *bdata)
 {
  double a, fval;
  int i;
 
  if(bdata->verbose>5) {printf("bobyqb_xupdate()\n"); fflush(stdout);}
  fval=bdata->fval[bdata->kopt-1];
  //printf("fsave=%g fval=%g minf=%g\n", bdata->fsave, fval, bdata->minf);
  if(fval<=bdata->fsave) {
  for(i=0; i<bdata->n; i++) {
  a=fmax(bdata->xl[i], bdata->xbase[i]+bdata->xopt[i]);
  bdata->x[i]=fmin(a, bdata->xu[i]);
  if(bdata->xopt[i]==bdata->sl[i]) bdata->x[i]=bdata->xl[i];
  if(bdata->xopt[i]==bdata->su[i]) bdata->x[i]=bdata->xu[i];
  }
  bdata->minf = fval;
  /* Update also the full parameter list */
  bobyqa_xfull(bdata);
  } else {
  bdata->minf = bdata->fsave; // Added by VO 2012-09-10
  }
 }
 /******************************************************************************/
 void bobyqb_update_gopt(bobyqa_data *bdata)
 {
  int i, j, k;
  double dtemp;
 
  if(bdata->verbose>5) {printf("update_gopt()\n"); fflush(stdout);}
  for(j=k=0; j<bdata->n; j++) for(i=0; i<=j; i++, k++) {
  if(i<j) bdata->gopt[j]+=bdata->hq[k]*bdata->xopt[i];
  bdata->gopt[i]+=bdata->hq[k]*bdata->xopt[j];
  }
  if(bdata->nevals<=bdata->npt) return;
  for(k=0; k<bdata->npt; k++) {
  dtemp=0.0;
  for(j=0; j<bdata->n; j++)
  dtemp+=bdata->xpt[k + j*bdata->npt]*bdata->xopt[j];
  dtemp*=bdata->pq[k];
  for(j=0; j<bdata->n; j++)
  bdata->gopt[j]+=dtemp*bdata->xpt[k + j*bdata->npt];
  }
  return;
 }
 /******************************************************************************/
 void bobyqb_shift_xbase(bobyqa_data *bdata)
 {
  double fracsq, sumpq=0.0, sum, temp, sumz, sumw;
  int i, j, k, jj;
 
  if(bdata->verbose>5) {printf("shift_xbase()\n"); fflush(stdout);}
  fracsq=0.25*bdata->xoptsq;
  for(k=0; k<bdata->npt; k++) {
  sumpq+=bdata->pq[k];
  sum=-0.5*bdata->xoptsq;
  if(!isfinite(sumpq) || !isfinite(sum)) {
  if(bdata->verbose>0) {
  printf("INF in shift_xbase(): sumpq=%E sum=%E\n", sumpq, sum);
  exit(345);
  }
  }
  for(i=0; i<bdata->n; i++) sum+=bdata->xpt[k+i*bdata->npt]*bdata->xopt[i];
  // bdata->w2npt[bdata->npt+k]=sum; // Original code
  bdata->w2npt[k]=sum;
 
 
  temp=fracsq-0.5*sum; //printf("temp=%.15E\n", temp);
  for(i=0; i<bdata->n; i++) {
  bdata->wn[i]=bdata->bmat[k+i*bdata->ndim];
  bdata->vlag[i]=sum*bdata->xpt[k+i*bdata->npt] + temp*bdata->xopt[i];
  for(j=0; j<=i; j++)
  bdata->bmat[bdata->npt+i + j*bdata->ndim] +=
  bdata->wn[i]*bdata->vlag[j] + bdata->vlag[i]*bdata->wn[j];
  }
  }
 
 
  /* Then the revisions of BMAT that depend on ZMAT are calculated. */
  for(jj=0; jj<bdata->nptm; jj++) {
  sumz=sumw=0.0;
  for(k=0; k<bdata->npt; k++) {
  sumz+=bdata->zmat[k+jj*bdata->npt];
  // Original code:
  // bdata->vlag[k]=bdata->w2npt[bdata->npt+k]*bdata->zmat[k+jj*bdata->npt];
  bdata->vlag[k]=bdata->w2npt[k]*bdata->zmat[k+jj*bdata->npt];
  sumw+=bdata->vlag[k];
  }
  for(i=0; i<bdata->n; i++) {
  sum=(fracsq*sumz - 0.5*sumw)*bdata->xopt[i];
  for(k=0; k<bdata->npt; k++) sum+=bdata->vlag[k]*bdata->xpt[k+i*bdata->npt];
  bdata->wn[i]=sum;
  for(k=0; k<bdata->npt; k++)
  bdata->bmat[k+i*bdata->ndim] += sum*bdata->zmat[k+jj*bdata->npt];
  }
  for(i=0; i<bdata->n; i++) for(j=0; j<=i; j++)
  bdata->bmat[i+bdata->npt + j*bdata->ndim] += bdata->wn[i]*bdata->wn[j];
  }
 
 
  /* The following instructions complete the shift, including the changes
  to the second derivative parameters of the quadratic model. */
  for(i=jj=0; i<bdata->n; i++) {
  bdata->wn[i]=-0.5*sumpq*bdata->xopt[i];
  for(k=0; k<bdata->npt; k++) {
  bdata->wn[i] += bdata->pq[k]*bdata->xpt[k+i*bdata->npt];
  bdata->xpt[k+i*bdata->npt]-=bdata->xopt[i];
  }
  for(j=0; j<=i; j++, jj++) {
  bdata->hq[jj] +=
  bdata->wn[j]*bdata->xopt[i] + bdata->xopt[j]*bdata->wn[i];
  bdata->bmat[bdata->npt+j+i*bdata->ndim] =
  bdata->bmat[bdata->npt+i+j*bdata->ndim];
  }
  }
  for(i=0; i<bdata->n; i++) {
  bdata->xbase[i]+=bdata->xopt[i]; bdata->xnew[i]-=bdata->xopt[i];
  bdata->sl[i] -= bdata->xopt[i]; bdata->su[i] -= bdata->xopt[i];
  bdata->xopt[i] = 0.0;
  }
  bdata->xoptsq=0.0;
 }
 /******************************************************************************/
 
 /******************************************************************************/
 void bobyqb_vlag_beta_for_d(bobyqa_data *bdata)
 {
  int i, j, k;
  double dx, bsum, sum, suma, sumb;
 
  if(bdata->verbose>5) {printf("bobyqb_vlag_beta_for_d()\n"); fflush(stdout);}
  for(k=0; k<bdata->npt; k++) {
  for(j=0, suma=sumb=sum=0.0; j<bdata->n; j++) {
  suma+=bdata->xpt[k+j*bdata->npt]*bdata->dtrial[j];
  sumb+=bdata->xpt[k+j*bdata->npt]*bdata->xopt[j];
  sum+=bdata->bmat[k+j*bdata->ndim]*bdata->dtrial[j];
  }
  bdata->w2npt[k]=suma*(0.5*suma+sumb); bdata->vlag[k]=sum;
  bdata->w2npt[bdata->npt+k]=suma;
  }
  for(j=0, bdata->beta=0.0; j<bdata->nptm; j++) {
  for(k=0, sum=0.0; k<bdata->npt; k++)
  sum+=bdata->zmat[k+j*bdata->npt]*bdata->w2npt[k];
  bdata->beta-=sum*sum;
  for(k=0; k<bdata->npt; k++)
  bdata->vlag[k]+=sum*bdata->zmat[k+j*bdata->npt];
  }
  bdata->dsq=bsum=dx=0.0;
  for(j=0; j<bdata->n; j++) {
  bdata->dsq += bdata->dtrial[j]*bdata->dtrial[j];
  for(k=0, sum=0.0; k<bdata->npt; k++)
  sum+=bdata->w2npt[k]*bdata->bmat[k+j*bdata->ndim];
  bsum+=sum*bdata->dtrial[j];
  for(i=0; i<bdata->n; i++)
  sum+=bdata->bmat[bdata->npt+j+i*bdata->ndim]*bdata->dtrial[i];
  bdata->vlag[bdata->npt+j]=sum; bsum+=sum*bdata->dtrial[j];
  dx+=bdata->dtrial[j]*bdata->xopt[j];
  }
  bdata->beta+= dx*dx + bdata->dsq*(bdata->xoptsq+dx+dx+0.5*bdata->dsq) - bsum;
  bdata->vlag[bdata->kopt-1]+=1.0;
 }
 /******************************************************************************/
 int bobyqb_calc_with_xnew(bobyqa_data *bdata)
 {
  int i, ih, j, k, nh, ksav;
  double d1, diff, temp, den, densav, hdiag, pqold;
  double suma, sumb, sum, gqsq, gisq;
 
  if(bdata->verbose>5) {printf("calc_with_xnew()\n"); fflush(stdout);}
 
  /* Put the variables for the next calculation of the objective function
  in XNEW, with any adjustments for the bounds */
  for (i=0; i<bdata->n; i++) {
  d1=fmax(bdata->xl[i], bdata->xbase[i]+bdata->xnew[i]);
  bdata->x[i]=fmin(d1, bdata->xu[i]);
  if(bdata->xnew[i]==bdata->sl[i]) bdata->x[i]=bdata->xl[i];
  if(bdata->xnew[i]==bdata->su[i]) bdata->x[i]=bdata->xu[i];
  }
 
  /* Calculate the value of the objective function at XBASE+XNEW, unless
  the limit on the number of calculations of F has been reached. */
  if((bdata->maxeval>0) && (bdata->nevals>=bdata->maxeval)) {
  if(bdata->verbose>3) printf("BOBYQA_MAXEVAL_REACHED\n");
  bdata->rc = BOBYQA_MAXEVAL_REACHED;
  }
  if(bdata->rc != BOBYQA_SUCCESS) {
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
 
  /* Update the full parameter list for objf() */
  bdata->newf=bobyqa_x_funcval(bdata, bdata->x);
  if(bdata->ntrits == -1) {
  bdata->fsave = bdata->newf;
  if(bdata->verbose>3) printf("BOBYQA_XTOL_REACHED 1\n");
  bdata->rc = BOBYQA_XTOL_REACHED;
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
 
  if(bdata->newf < bdata->minf_max) {
  bdata->minf = bdata->newf;
  if(bdata->verbose>3) printf("BOBYQA_MINF_MAX_REACHED\n");
  return BOBYQA_MINF_MAX_REACHED;
  }
 
  /* Use the quadratic model to predict the change in F due to the step D,
  and set DIFF to the error of this prediction. */
  bdata->fopt=bdata->fval[bdata->kopt-1]; bdata->vquad=0.0;
  for(j=ih=0; j<bdata->n; j++) {
  bdata->vquad += bdata->dtrial[j]*bdata->gopt[j];
  for(i=0; i<=j; i++, ih++) {
  temp = bdata->dtrial[i]*bdata->dtrial[j]; if(i==j) temp*=0.5;
  bdata->vquad += bdata->hq[ih]*temp;
  }
  }
  for(k=0; k<bdata->npt; k++)
  bdata->vquad += 0.5*bdata->pq[k]*(bdata->w2npt[bdata->npt+k]*bdata->w2npt[bdata->npt+k]);
 
  diff = bdata->newf - bdata->fopt - bdata->vquad;
  bdata->diffc=bdata->diffb; bdata->diffb=bdata->diffa;
  bdata->diffa=fabs(diff);
  if(bdata->dnorm > bdata->rho) bdata->nfsav=bdata->nevals;
 
  /* Pick the next value of DELTA after a trust region step. */
  if(bdata->ntrits > 0 && bdata->vquad >= 0.0) {
  /* Return from BOBYQA because a trust region step has failed to reduce Q. */
 #if(0) // this is the original way of doing this
  if(bdata->verbose>3)
  printf("BOBYQA_ROUNDOFF_LIMITED 3; ntrits=%d vquad=%g\n",
  bdata->ntrits, bdata->vquad);
  bdata->rc = BOBYQA_ROUNDOFF_LIMITED; /* or FTOL_REACHED? */
  bobyqb_xupdate(bdata); //*bdata.minf = f;
  return bdata->rc;
 #else // this might work better with scales
  bdata->fsave = bdata->newf;
  if(bdata->verbose>3) printf("BOBYQA_XTOL_REACHED 2\n");
  bdata->rc = BOBYQA_XTOL_REACHED;
  bobyqb_xupdate(bdata);
  return bdata->rc;
 #endif
  }
 
  if(bdata->ntrits > 0) {
  bdata->ratio=(bdata->newf-bdata->fopt)/bdata->vquad;
  if(bdata->ratio <= 0.1) {
  bdata->delta = fmin(0.5*bdata->delta, bdata->dnorm);
  } else if(bdata->ratio <= .7) {
  bdata->delta = fmax(0.5*bdata->delta, bdata->dnorm);
  } else {
  bdata->delta = fmax(0.5*bdata->delta, bdata->dnorm + bdata->dnorm);
  }
  if(bdata->delta <= 1.5*bdata->rho) bdata->delta=bdata->rho;
 
  /* Recalculate KNEW and DENOM if the new F is less than FOPT. */
  if(bdata->newf < bdata->fopt) {
  ksav=bdata->knew; densav=bdata->denom;
  bdata->delsq=bdata->delta*bdata->delta; bdata->scaden=0.0;
  bdata->biglsq=0.0; bdata->knew=0;
  for(k=0; k<bdata->npt; k++) {
  for(j=0, hdiag=0.0; j<bdata->nptm; j++)
  hdiag+=bdata->zmat[k+j*bdata->npt]*bdata->zmat[k+j*bdata->npt];
  if(!isfinite(hdiag) && bdata->verbose>0)
  printf("INF in calc_with_xnew(): k=%d hdiag=%.10E\n", k, hdiag);
  den=bdata->beta*hdiag + bdata->vlag[k]*bdata->vlag[k];
  if(!isfinite(den) && bdata->verbose>0) {
  printf("INF in calc_with_xnew(): k=%d den=%.10E\n", k, den);
  }
  for(j=0, bdata->distsq=0.0; j<bdata->n; j++) {
  d1=bdata->xpt[k+j*bdata->npt]-bdata->xnew[j];
  bdata->distsq+=d1*d1;
  }
  if(!isfinite(bdata->distsq) && bdata->verbose>0) {
  printf("INF in calc_with_xnew(): k=%d bdata->distsq=%.10E\n",
  k, bdata->distsq);
  }
  d1=bdata->distsq/bdata->delsq; temp=fmax(1.0, d1*d1);
  if(temp*den > bdata->scaden) {
  bdata->scaden=temp*den; bdata->knew=k+1; bdata->denom=den;}
  bdata->biglsq=fmax(bdata->biglsq, bdata->vlag[k]*bdata->vlag[k]*temp);
  }
  if(bdata->scaden <= 0.5*bdata->biglsq) {
  bdata->knew=ksav; bdata->denom=densav;}
  }
  }
 
  /* Update BMAT and ZMAT, so that the KNEW-th interpolation point can be
  moved. Also update the second derivative terms of the model. */
  bobyqa_update(bdata);
  pqold=bdata->pq[bdata->knew-1]; bdata->pq[bdata->knew-1]=0.0;
  for(i=ih=0; i<bdata->n; i++) {
  temp=pqold*bdata->xpt[bdata->knew-1 + i * bdata->npt];
  for(j=0; j<=i; j++, ih++)
  bdata->hq[ih]+=temp*bdata->xpt[bdata->knew-1 + j*bdata->npt];
  }
  for(j=0; j<bdata->nptm; j++) {
  temp=diff*bdata->zmat[bdata->knew-1+j*bdata->npt];
  for(k=0; k<bdata->npt; k++) bdata->pq[k]+=temp*bdata->zmat[k+j*bdata->npt];
  }
 
  /* Include the new interpolation point, and make the changes to GOPT at
  the old XOPT that are caused by the updating of the quadratic model. */
  bdata->fval[bdata->knew-1]=bdata->newf;
  for(i=0; i<bdata->n; i++) {
  bdata->xpt[bdata->knew-1 + i*bdata->npt]=bdata->xnew[i];
  bdata->wn[i]=bdata->bmat[bdata->knew-1 + i*bdata->ndim];
  }
 
  for(k=0; k<bdata->npt; k++) {
  for(j=0, suma=0.0; j<bdata->nptm; j++) {
 #if(1) // modified by VO
  double v;
  v=bdata->zmat[bdata->knew-1 + j*bdata->npt]*bdata->zmat[k + j*bdata->npt];
  if(isfinite(v)) suma+=v;
  else if(bdata->verbose>0) {
  printf("INF in calc_with_xnew(v): k=%d j=%d a=%E b=%E\n",
  k, j, bdata->zmat[bdata->knew-1 + j*bdata->npt],
  bdata->zmat[k + j*bdata->npt]);
  }
 #else // original
  suma+=bdata->zmat[bdata->knew-1 + j*bdata->npt] *
  bdata->zmat[k + j*bdata->npt];
 #endif
  if(!isfinite(suma) && bdata->verbose>0) {
  printf("INF in calc_with_xnew(suma): k=%d j=%d a=%E b=%E\n", k, j,
  bdata->zmat[bdata->knew-1+j*bdata->npt], bdata->zmat[k+j*bdata->npt]);
  }
  }
  /* Detect singularity here (happens if too many iterations) */
  if(!isfinite(suma)) {
  if(bdata->verbose>0) printf("INF in calc_with_xnew: suma\n");
  if(bdata->verbose>3) printf("BOBYQA_ROUNDOFF_LIMITED 4\n");
  bdata->rc = BOBYQA_ROUNDOFF_LIMITED;
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
  for(j=0, sumb=0.0; j<bdata->n; j++)
  sumb+=bdata->xpt[k+j*bdata->npt]*bdata->xopt[j];
  temp=suma*sumb;
  for(j=0; j<bdata->n; j++)
  bdata->wn[j]+=temp*bdata->xpt[k+j*bdata->npt];
  }
  for(i=0; i<bdata->n; i++) bdata->gopt[i]+=diff*bdata->wn[i];
 
  /* Update XOPT, GOPT and bdata->kopt if the new calculated F is less than FOPT */
  if(!isfinite(bdata->fopt) || !isfinite(bdata->newf)) { // Added by VO 2012-05-24
  if(bdata->verbose>3) printf("BOBYQA_ROUNDOFF_LIMITED N\n");
  bdata->rc = BOBYQA_ROUNDOFF_LIMITED;
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
  if(bdata->newf < bdata->fopt) {
  bdata->kopt=bdata->knew; bdata->xoptsq=0.0;
  for(j=0, ih=0; j<bdata->n; j++) {
  bdata->xopt[j]=bdata->xnew[j];
  bdata->xoptsq += bdata->xopt[j]*bdata->xopt[j];
  for(i=0; i<=j; i++, ih++) {
  if(i<j) bdata->gopt[j]+=bdata->hq[ih]*bdata->dtrial[i];
  bdata->gopt[i]+=bdata->hq[ih]*bdata->dtrial[j];
  }
  }
  for(k=0; k<bdata->npt; k++) {
  for(j=0, temp=0.0; j<bdata->n; j++)
  temp+=bdata->xpt[k+j*bdata->npt]*bdata->dtrial[j];
  temp*=bdata->pq[k];
  for(i=0; i<bdata->n; i++) bdata->gopt[i]+=temp*bdata->xpt[k+i*bdata->npt];
  }
  /* Check against stopping criteria */
  if(1) { // isfinite(bdata->fopt) && isfinite(bdata->newf)) {
  /* decrease in absolute function value */
  if(fabs(bdata->fopt-bdata->newf) < bdata->ftol_abs) {
  if(bdata->verbose>10)
  printf("fopt=%.15E newf=%.15E ftol_abs=%.15E\n", bdata->fopt,
  bdata->newf, bdata->ftol_abs);
  if(bdata->verbose>3) printf("BOBYQA_ABSFTOL_REACHED 2a\n");
  bdata->rc = BOBYQA_ABSFTOL_REACHED;
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
  /* decrease in relative function value */
  if(fabs(bdata->fopt-bdata->newf) <
  bdata->ftol_rel*0.5*(fabs(bdata->newf)+fabs(bdata->fopt)) ) {
  if(bdata->verbose>3) printf("BOBYQA_RELFTOL_REACHED 2b\n");
  bdata->rc = BOBYQA_RELFTOL_REACHED;
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
  /* catch situation where both new and old function values equal zero */
  if(bdata->ftol_rel>0 && bdata->newf==bdata->fopt) {
  if(bdata->verbose>3) printf("BOBYQA_FTOL_REACHED 2c\n");
  bdata->rc = BOBYQA_FTOL_REACHED;
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
  }
  }
 
 
  if(bdata->ntrits<=0) return bdata->rc;
  /* Calculate the parameters of the least Frobenius norm interpolant to
  the current data, the gradient of this interpolant at XOPT being put
  into VLAG(NPT+I), I=1,2,...,N. */
  nh=bdata->n*(bdata->n+1)/2;
  for(k=0; k<bdata->npt; k++) {
  bdata->vlag[k]=bdata->fval[k]-bdata->fval[bdata->kopt-1];
  bdata->w2npt[k]=0.0;
  }
  for(j=0; j<bdata->nptm; j++) {
  for(k=0, sum=0.0; k<bdata->npt; k++)
  sum+=bdata->zmat[k+j*bdata->npt]*bdata->vlag[k];
  for(k=0; k<bdata->npt; k++)
  bdata->w2npt[k]+=sum*bdata->zmat[k+j*bdata->npt];
  }
  for(k=0; k<bdata->npt; k++) {
  for(j=0, sum=0.0; j<bdata->n; j++)
  sum+=bdata->xpt[k+j*bdata->npt]*bdata->xopt[j];
  bdata->w2npt[k+bdata->npt]=bdata->w2npt[k];
  bdata->w2npt[k]*=sum;
  }
  gqsq=gisq=0.0;
  for(i=0; i<bdata->n; i++) {
  for(k=0, sum=0.0; k<bdata->npt; k++)
  sum+=bdata->bmat[k+i*bdata->ndim]*bdata->vlag[k] +
  bdata->xpt[k+i*bdata->npt]*bdata->w2npt[k];
  if(bdata->xopt[i]==bdata->sl[i]) {
  d1=fmin(0.0, bdata->gopt[i]); gqsq+=d1*d1;
  d1=fmin(0.0, sum); gisq+=d1*d1;
  } else if(bdata->xopt[i]==bdata->su[i]) {
  d1=fmax(0.0, bdata->gopt[i]); gqsq+=d1*d1;
  d1=fmax(0.0, sum); gisq+=d1*d1;
  } else {
  d1=bdata->gopt[i]; gqsq+=d1*d1; gisq+=sum*sum;
  }
  bdata->vlag[bdata->npt+i]=sum;
  }
 
  /* Test whether to replace the new quadratic model by the least Frobenius
  norm interpolant, making the replacement if the test is satisfied. */
  bdata->itest++; if(gqsq<10.0*gisq) bdata->itest=0;
  if(bdata->itest>=3) {
  for(i=0; i<bdata->npt || i<nh; i++) {
  if(i<bdata->n) bdata->gopt[i]=bdata->vlag[bdata->npt+i];
  if(i<bdata->npt) bdata->pq[i]=bdata->w2npt[bdata->npt+i];
  if(i<nh) bdata->hq[i]=0.0;
  bdata->itest=0;
  }
  }
 
  return bdata->rc;
 }
 /******************************************************************************/
 void bobyqb_next_rho_delta(bobyqa_data *bdata)
 {
  if(bdata->verbose>5) printf("bobyqb_next_rho_delta()\n");
  bdata->delta=0.5*bdata->rho;
  bdata->ratio = bdata->rho / bdata->rhoend;
  if(bdata->ratio <= 16.) {
  bdata->rho = bdata->rhoend;
  } else if(bdata->ratio <= 250.) {
  bdata->rho = sqrt(bdata->ratio) * bdata->rhoend;
  } else {
  bdata->rho *= 0.1;
  }
  bdata->delta = fmax(bdata->delta, bdata->rho);
  bdata->ntrits=0; bdata->nfsav=bdata->nevals;
 }
 /******************************************************************************/
 int bobyqb_do_rescue(bobyqa_data *bdata)
 {
  int i, rc=0;
 
  if(bdata->verbose>5) {printf("bobyqb_do_rescue()\n"); fflush(stdout);}
  /* XBASE is also moved to XOPT by a call of RESCUE. This calculation is
  more expensive than the previous shift, because new matrices BMAT and
  ZMAT are generated from scratch, which may include the replacement of
  interpolation points whose positions seem to be causing near linear
  dependence in the interpolation conditions. Therefore RESCUE is called
  only if rounding errors have reduced by at least a factor of two the
  denominator of the formula for updating the H matrix. It provides a
  useful safeguard, but is not invoked in most applications of BOBYQA. */
  bdata->nfsav = bdata->nevals;
  bdata->kbase = bdata->kopt;
  rc = bobyqa_rescue(bdata);
 
  /* XOPT is updated now in case the branch below to label 720 is taken.
  Any updating of GOPT occurs after the branch below to label 20, which
  leads to a trust region iteration as does the branch to label 60. */
  bdata->xoptsq=0.0;
  if(bdata->kopt!=bdata->kbase) {
  for(i=0; i<bdata->n; i++) {
  bdata->xopt[i]=bdata->xpt[bdata->kopt-1 + i*bdata->npt];
  bdata->xoptsq+=bdata->xopt[i]*bdata->xopt[i];
  }
  }
  if(rc != BOBYQA_SUCCESS) {
  bdata->rc = rc;
  if(bdata->verbose>3) printf("rescue() not successful\n");
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
  bdata->nresc = bdata->nevals;
  if(bdata->nfsav < bdata->nevals) {
  bdata->nfsav = bdata->nevals;
  /* Update GOPT if necessary after each call of RESCUE that makes a call of
  objf. */
  if(bdata->kopt != bdata->kbase) bobyqb_update_gopt(bdata);
  }
  return BOBYQA_SUCCESS;
 }
 /******************************************************************************/
 int bobyqb_part(bobyqa_data *bdata)
 {
  int i, j, k, rescue;
  double d1, den, hdiag, temp;
 
  if(bdata->verbose>5) {printf("bobyqb_part()\n"); fflush(stdout);}
  do {
  rescue=0;
 
  /* Calculate VLAG and BETA for the current choice of D. The scalar
  product of D with XPT(K,.) is going to be held in W(NPT+K) for
  use when VQUAD is calculated. */
  bobyqb_vlag_beta_for_d(bdata);
 
  /* If NTRITS is zero, the denominator may be increased by replacing
  the step D of ALTMOV by a Cauchy step. Then RESCUE may be called if
  rounding errors have damaged the chosen denominator. */
  if(bdata->ntrits == 0) {
  d1=bdata->vlag[bdata->knew-1];
  bdata->denom = d1*d1 + bdata->alpha * bdata->beta;
  // VO: tried this, did not seem to make any better
  // while(bdata->denom<0.999999999*bdata->cauchy&&bdata->cauchy>1.0E-10) {
  while(bdata->denom < bdata->cauchy && bdata->cauchy > 0.0) {
  for(i=0; i<bdata->n; i++) {
  bdata->xnew[i]=bdata->xalt[i];
  bdata->dtrial[i]=bdata->xnew[i]-bdata->xopt[i];
  }
  bdata->cauchy=0.0;
  bobyqb_vlag_beta_for_d(bdata);
  d1=bdata->vlag[bdata->knew-1];
  bdata->denom = d1*d1 + bdata->alpha * bdata->beta;
  }
  d1 = bdata->vlag[bdata->knew-1];
  // For testing, you can request rescue() here. DO NOT LEAVE IT HERE!!!!
  //if(bdata->rescue_nr<1 && bdata->stop->nevals>400) rescue=1; else
  if(bdata->denom <= 0.5*d1*d1) {
  // in practise this happens only if either alpha or beta is negative
  if(bdata->verbose>4)
  printf("1: denom=%g vs 0.5*vlag*vlag=%g\n", bdata->denom, 0.5*d1*d1);
  //printf("denom=%g d1^2=%g\n", bdata->denom, d1*d1);
  if(bdata->verbose>0)
  printf("too much cancellation 1; nevals=%d nresc=%d\n",
  bdata->nevals, bdata->nresc);
  if(bdata->nevals > bdata->nresc) {
  rescue=1; //goto L190;
  } else {
  /* Return from BOBYQA because of much cancellation in a denominator */
  bdata->rc = BOBYQA_ROUNDOFF_LIMITED; // do not change this value
  // unless you change the following test too
  if(bdata->verbose>3) printf("BOBYQA_ROUNDOFF_LIMITED 1\n");
  bobyqb_xupdate(bdata);
  //return bdata->rc;
  }
  }
 
  } else {
 
  /* Alternatively, if NTRITS is positive, then set KNEW to the index of
  the next interpolation point to be deleted to make room for a trust
  region step. Again RESCUE may be called if rounding errors have damaged
  the chosen denominator, which is the reason for attempting to select
  KNEW before calculating the next value of the objective function. */
  bdata->delsq = bdata->delta * bdata->delta;
  bdata->scaden = bdata->biglsq =0.0; bdata->knew=0;
  for(k=0; k<bdata->npt; k++) {
  if(k==bdata->kopt-1) continue;
  for(j=0, hdiag=0.0; j<bdata->nptm; j++)
  hdiag += bdata->zmat[k+j*bdata->npt]*bdata->zmat[k+j*bdata->npt];
  den= bdata->beta*hdiag + bdata->vlag[k]*bdata->vlag[k];
  for(j=0, bdata->distsq=0.0; j<bdata->n; j++) {
  d1=bdata->xpt[k+j*bdata->npt]-bdata->xopt[j];
  bdata->distsq += d1*d1;
  }
  d1=bdata->distsq/bdata->delsq; temp=fmax(1.0, d1*d1);
  if(temp*den > bdata->scaden) {
  bdata->scaden = temp*den; bdata->knew=k+1; bdata->denom=den;}
  bdata->biglsq=fmax(bdata->biglsq, (bdata->vlag[k]*bdata->vlag[k])*temp);
  }
  //printf("2:scaden=%g vs 0.5*biglsq=%g\n",bdata->scaden,0.5*bdata->biglsq);
  if(bdata->scaden <= 0.5*bdata->biglsq) {
  if(bdata->verbose>0)
  printf("too much cancellation 2; nevals=%d nresc=%d\n",
  bdata->nevals, bdata->nresc);
  if(bdata->nevals > bdata->nresc) {
  rescue=1;
  } else {
  /* Return from BOBYQA because of much cancellation in denominator. */
  if(bdata->verbose>3) printf("BOBYQA_ROUNDOFF_LIMITED 2\n");
  if(bdata->verbose>4)
  printf("scaden=%.15E 0.5*biglsq=%.15E\n",
  bdata->scaden, 0.5*bdata->biglsq);
  bdata->rc = BOBYQA_ROUNDOFF_LIMITED;
  bobyqb_xupdate(bdata);
  //return bdata->rc;
  }
  }
  }
  if(bdata->rc == BOBYQA_ROUNDOFF_LIMITED) return -1;
  if(rescue==1) {
  if(bobyqb_do_rescue(bdata)!=BOBYQA_SUCCESS) return -1; //bdata->rc;
  if(bdata->nfsav < bdata->nevals || bdata->ntrits>0) {
  return 1;
  }
 
  /* Pick two alternative vectors of variables, relative to XBASE, that
  are suitable as new positions of the KNEW-th interpolation point.
  Firstly, XNEW is set to the point on a line through XOPT and another
  interpolation point that minimizes the predicted value of the next
  denominator, subject to ||XNEW - XOPT|| .LEQ. ADELT and to the SL
  and SU bounds. Secondly, XALT is set to the best feasible point on
  a constrained version of the Cauchy step of the KNEW-th Lagrange
  function, the corresponding value of the square of this function
  being returned in CAUCHY. The choice between these alternatives is
  oing to be made when the denominator is calculated. */
  bobyqa_altmov(bdata);
  for(i=0; i<bdata->n; i++) bdata->dtrial[i]=bdata->xnew[i]-bdata->xopt[i];
  }
  } while(rescue!=0);
 
  return 0;
 }
 /******************************************************************************/
 int bobyqb_ip_dist(bobyqa_data *bdata)
 {
  int j, k;
  double sum, d;
 
  if(bdata->verbose>5) {printf("ip_dist()\n"); fflush(stdout);}
  for(k=0, bdata->knew=0; k<bdata->npt; k++) {
  for(j=0, sum=0.0; j<bdata->n; j++) {
  d=bdata->xpt[k+j*bdata->npt] - bdata->xopt[j];
  sum+=d*d;
  }
  if(sum > bdata->distsq) {bdata->knew=k+1; bdata->distsq=sum;}
  }
  if(bdata->knew==0) return 0; else return 1;
 }
 /******************************************************************************/
 void bobyqb_ip_alternative(bobyqa_data *bdata)
 {
  int i;
  double d, dist;
 
  if(bdata->verbose>5) {printf("ip_alternative()\n"); fflush(stdout);}
  dist = sqrt(bdata->distsq);
  if(bdata->ntrits == -1) {
  bdata->delta=fmin(0.1*bdata->delta, 0.5*dist);
  if(bdata->delta <= 1.5*bdata->rho) bdata->delta=bdata->rho;
  }
  bdata->ntrits=0;
  d=fmin(0.1*dist, bdata->delta);
  bdata->adelt = fmax(d, bdata->rho);
  bdata->dsq= bdata->adelt * bdata->adelt;
  /* Severe cancellation is likely to occur if XOPT is too far from XBASE. */
  /* If the following test holds, then XBASE is shifted so that XOPT becomes */
  /* zero. The appropriate changes are made to BMAT and to the second */
  /* derivatives of the current model, beginning with the changes to BMAT */
  /* that do not depend on ZMAT. VLAG is used temporarily for working space. */
  if(bdata->dsq <= bdata->xoptsq*0.001) bobyqb_shift_xbase(bdata);
 
  bobyqa_altmov(bdata);
  for(i=0; i<bdata->n; i++) bdata->dtrial[i]=bdata->xnew[i]-bdata->xopt[i];
 }
 /******************************************************************************/
 bobyqa_result bobyqb(
  bobyqa_data *bdata
 ) {
  if(bdata->verbose>2) {printf("bobyqb()\n"); fflush(stdout);}
 
  int i, j, k;
  double curv;
  double bdtol;
  double errbig;
  double bdtest;
  double frhosq;
  bobyqa_result rc2;
  double d1;
 
 
  /* The call of PRELIM sets the elements of XBASE, XPT, FVAL, GOPT, HQ, PQ,
  BMAT and ZMAT for the first iteration, with the corresponding values of
  of NF and KOPT, which are the number of calls of objf() so far and the
  index of the interpolation point at the trust region centre. Then the
  initial XOPT is set too. The branch to label 720 occurs if MAXFUN is
  less than NPT. GOPT will be updated if KOPT is different from KBASE. */
  rc2 = bobyqa_prelim(bdata);
 
  for(i=0, bdata->xoptsq=0.0; i<bdata->n; i++) {
  bdata->xopt[i] = bdata->xpt[bdata->kopt-1 +i*bdata->npt];
  bdata->xoptsq+=bdata->xopt[i]*bdata->xopt[i];
  }
  bdata->fsave = bdata->fval[0];
  if (rc2 != BOBYQA_SUCCESS) {
  bdata->rc = rc2;
  if(bdata->verbose>3) printf("prelim() was not successful\n");
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
  bdata->kbase = 1;
 
  /* Complete the settings that are required for the iterative procedure. */
  bdata->rho=bdata->rhobeg;
  bdata->delta= bdata->rho;
  bdata->nresc= bdata->nevals;
  bdata->ntrits= 0;
  bdata->diffa=bdata->diffb=bdata->diffc= 0.0;
  bdata->ratio =0.0; //=1.0;
  bdata->itest= 0;
  bdata->nfsav= bdata->nevals;
 
  /* Update GOPT if necessary before the first iteration and after each
  call of RESCUE that makes a call of objf(). */
  if (bdata->kopt != bdata->kbase) bobyqb_update_gopt(bdata);
 
  do { // start main loop
  /* Generate the next point in the trust region that provides a small value
  of the quadratic model subject to the constraints on the variables.
  The int NTRITS is set to the number "trust region" iterations that
  have occurred since the last "alternative" iteration. If the length
  of XNEW-XOPT is less than 0.5*RHO, however, then there is a branch to
  label 650 or 680 with NTRITS=-1, instead of calculating F at XNEW. */
  bobyqa_trsbox(bdata);
  bdata->dnorm = fmin(bdata->delta, sqrt(bdata->dsq));
 
 #if(0) // original
  if(bdata->dnorm < 0.5 * bdata->rho) {
 #else
  if(bdata->dnorm>0.0 && bdata->dnorm < 0.5 * bdata->rho) {
 #endif
  if(bdata->verbose>10) {
  printf("ntrits set to -1; A\n");
  printf("bdata->dnorm=%.15E 0.5*bdata->rho=%.15E\n",
  bdata->dnorm, 0.5*bdata->rho);
  printf("delta=%.15E dsq=%.15E\n", bdata->delta, bdata->dsq);
  }
  bdata->ntrits = -1;
  d1=10.0*bdata->rho; bdata->distsq = d1*d1;
  if(bdata->nevals <= bdata->nfsav + 2) {
  if(bdata->verbose>10) {
  printf("nevals<=nfsav+2 (nevals=%d nfsav=%d)\n",
  bdata->nevals, bdata->nfsav);
  }
  } else {
 
  /* The following choice between labels 650 and 680 depends on whether or
  not our work with the current RHO seems to be complete. Either RHO is
  decreased or termination occurs if the errors in the quadratic model
  at the last three interpolation points compare favourably with
  predictions of likely improvements to the model within distance
  0.5*RHO of XOPT. */
  d1 = fmax(bdata->diffa, bdata->diffb); errbig = fmax(d1, bdata->diffc);
  frhosq = bdata->rho * .125 * bdata->rho;
  if(bdata->_crvmin<=0.0 || errbig <= frhosq*bdata->_crvmin) {
  bdtest=bdtol= errbig/bdata->rho;
 
  for(j=0; j<bdata->n; j++) {
  bdtest=bdtol;
  if(bdata->xnew[j]==bdata->sl[j]) bdtest=bdata->gnew[j];
  if(bdata->xnew[j]==bdata->su[j]) bdtest=-bdata->gnew[j];
  if(bdtest<bdtol) {
  curv=bdata->hq[(j+1 + (j+1)*(j+1))/2 - 1];
  for(k=0; k<bdata->npt; k++) {
  d1=bdata->xpt[k+j*bdata->npt]; curv+=bdata->pq[k]*(d1*d1);
  }
  bdtest += 0.5*curv*bdata->rho;
  if(bdtest < bdtol) break;
  }
  }
  if(bdtest>=bdtol) {
  /* The calculations with the current value of RHO are complete.
  Pick the next values of RHO and DELTA. */
  if (bdata->rho > bdata->rhoend) {
  bobyqb_next_rho_delta(bdata);
  continue;
  }
 
  /* Return from the calculation, after another Newton-Raphson step,
  if it is too short to have been tried before. */
  if(bdata->ntrits != -1) {
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
  bdata->rc=bobyqb_calc_with_xnew(bdata);
  if(bdata->rc!=BOBYQA_SUCCESS) return bdata->rc;
  /* If a trust region step has provided a sufficient decrease in F,
  then branch for another trust region calculation.
  The case NTRITS=0 occurs when the new interpolation point was
  reached by an alternative step. */
  if (bdata->ntrits==0 || bdata->newf<=bdata->fopt+0.1*bdata->vquad) {
  continue;
  }
 
  /* Alternatively, find out if the interpolation points are close
  enough to the best point so far. */
  d1=fmax(2.0*bdata->delta, 10.0*bdata->rho);
  bdata->distsq=d1*d1;
  }
  }
  }
 
  } else {
 
  bdata->ntrits++;
 
  /* Severe cancellation is likely to occur if XOPT is too far from XBASE.
  If the following test holds, then XBASE is shifted so that XOPT becomes
  zero. The appropriate changes are made to BMAT and to the second
  derivatives of the current model, beginning with the changes to BMAT
  that do not depend on ZMAT.
  VLAG is used temporarily for working space */
  if(bdata->dsq <= bdata->xoptsq * .001) bobyqb_shift_xbase(bdata);
 
  if (bdata->ntrits == 0) {
  bobyqa_altmov(bdata);
  for(i=0; i<bdata->n; i++) bdata->dtrial[i]=bdata->xnew[i]-bdata->xopt[i];
  }
 
  i=bobyqb_part(bdata);
  if(i==-1) return bdata->rc;
  if(i==1) continue;
 
  bdata->rc=bobyqb_calc_with_xnew(bdata);
  if(bdata->rc!=BOBYQA_SUCCESS) return bdata->rc;
 
  /* If a trust region step has provided a sufficient decrease in F, then
  branch for another trust region calculation. The case NTRITS=0 occurs
  when the new interpolation point was reached by an alternative step. */
  if (bdata->ntrits==0 || bdata->newf <= bdata->fopt+0.1*bdata->vquad) {
  continue;
  }
 
  /* Alternatively, find out if the interpolation points are close enough
  to the best point so far. */
  d1=fmax(2.0*bdata->delta, 10.0*bdata->rho);
  bdata->distsq=d1*d1;
 
  }
  while(1) {
  /* Check if interpolation points are close enough, and update distsq
  if necessary */
  i=bobyqb_ip_dist(bdata);
 
  /* If not close enough (KNEW is positive),
  then ALTMOV finds alternative new positions for
  the KNEW-th interpolation point within distance ADELT of XOPT. */
  if(i!=0) { // T?st? iffist? ei jatketa alle
  /* Find alternative new positions for the KNEWth interpolation point
  within distance ADELT of XOPT. */
  bobyqb_ip_alternative(bdata);
  i=bobyqb_part(bdata);
  if(i==-1) return bdata->rc;
  if(i==1) break;
 
  bdata->rc=bobyqb_calc_with_xnew(bdata);
  if(bdata->rc!=BOBYQA_SUCCESS) return bdata->rc;
 
  /* If a trust region step has provided a sufficient decrease in F, then
  branch for another trust region calculation. The case NTRITS=0 occurs
  when the new interpolation point was reached by an alternative step. */
  if (bdata->ntrits == 0 || bdata->newf <= bdata->fopt + 0.1*bdata->vquad) {
  break;
  }
 
  /* Alternatively, find out if the interpolation points are close enough
  to the best point so far. */
  d1=fmax(2.0*bdata->delta, 10.0*bdata->rho);
  bdata->distsq=d1*d1;
 
  continue;
  }
  /* Another trust region iteration, unless the calculations with the
  current RHO are complete. */
  if(bdata->ntrits != -1) {
  if(bdata->ratio>0.0 || fmax(bdata->delta, bdata->dnorm) > bdata->rho) {
  break;
  }
  }
 
  /* The calculations with the current value of RHO are complete. Pick the
  next values of RHO and DELTA. */
  if (bdata->rho > bdata->rhoend) {
  bobyqb_next_rho_delta(bdata);
  break;
  }
 
  /* Return from the calculation, after another Newton-Raphson step, if
  it is too short to have been tried before */
  if (bdata->ntrits == -1) {
  bdata->rc=bobyqb_calc_with_xnew(bdata);
  if(bdata->rc!=BOBYQA_SUCCESS) return bdata->rc;
  /* If a trust region step has provided a sufficient decrease in F, then
  branch for another trust region calculation. The case NTRITS=0 occurs
  when the new interpolation point was reached by an alternative step. */
  if (bdata->ntrits == 0 || bdata->newf <= bdata->fopt+0.1*bdata->vquad) {
  break;
  }
  /* Alternatively, find out if the interpolation points are close enough
  to the best point so far. */
  d1=fmax(2.0*bdata->delta, 10.0*bdata->rho);
  bdata->distsq=d1*d1;
 
  continue;
  } else {
  bobyqb_xupdate(bdata);
  return bdata->rc;
  }
  }
  } while(1);
  // actually we should never reach this point
  return bdata->rc;
 } /* bobyqb() */
 /*****************************************************************************/
 
 /*****************************************************************************/
 // ALTMOV
 void bobyqa_altmov(
  bobyqa_data *bdata
 ) {
  bdata->altmov_nr++;
  if(bdata->verbose>3) {printf("bobyqa_altmov()\n"); fflush(stdout);}
 
  double d1, d2;
  int i, j, k;
  double ha, gw, diff;
  int ilbd, isbd;
  double slbd;
  int iubd;
  double vlag, subd, temp;
  int ksav;
  double step=0.0, curv;
  int iflag;
  double scale, csave=0.0, tempa, tempb, tempd, sumin, ggfree;
  int ibdsav=0;
  double dderiv, bigstp, predsq, presav, distsq, stpsav=0.0, wfixsq, wsqsav=0.0;
 
 
  /* Set the first NPT components of CCSTEP to the leading elements of the
  KNEW-th column of the H matrix. */
  for(k=0; k<bdata->npt; k++) bdata->hcol[k]=0.0;
  for(j=0; j<bdata->npt-bdata->n-1; j++) {
  temp = bdata->zmat[(bdata->knew-1) + j*bdata->npt];
  for(k=0; k<bdata->npt; k++)
  bdata->hcol[k] += temp * bdata->zmat[k + j*bdata->npt];
  }
  bdata->alpha = bdata->hcol[bdata->knew-1];
  ha = 0.5*bdata->alpha;
 
  /* Calculate the gradient of the KNEW-th Lagrange function at XOPT. */
  for(i=0; i<bdata->n; i++)
  bdata->glag[i]=bdata->bmat[bdata->knew-1 + i*bdata->ndim];
  for(k=0; k<bdata->npt; k++) {
  temp=0.0;
  for(j=0; j<bdata->n; j++) temp+=bdata->xpt[k + j*bdata->npt]*bdata->xopt[j];
  temp*=bdata->hcol[k];
  for(i=0; i<bdata->n; i++) bdata->glag[i]+=temp*bdata->xpt[k+i*bdata->npt];
  }
 
  /* Search for a large denominator along the straight lines through XOPT
  and another interpolation point. SLBD and SUBD will be lower and upper
  bounds on the step along each of these lines in turn. PREDSQ will be
  set to the square of the predicted denominator for each line. PRESAV
  will be set to the largest admissible value of PREDSQ that occurs. */
  presav=0.0;
  for(k=ksav=0; k<bdata->npt; k++) {
  if(k==bdata->kopt-1) continue;
  dderiv=distsq=0.0;
  for(i=0; i<bdata->n; i++) {
  temp = bdata->xpt[k + i*bdata->npt] - bdata->xopt[i];
  dderiv += bdata->glag[i]*temp;
  distsq += temp*temp;
  }
  subd = bdata->adelt / sqrt(distsq);
  slbd=-subd; ilbd=iubd=0;
  sumin = fmin(1.0, subd);
 
  /* Revise SLBD and SUBD if necessary because of the bounds in SL and SU. */
  for(i=0; i<bdata->n; i++) {
  temp = bdata->xpt[k + i*bdata->npt] - bdata->xopt[i];
  if(temp>0.0) {
  if(slbd*temp < bdata->sl[i]-bdata->xopt[i]) {
  slbd = (bdata->sl[i] - bdata->xopt[i]) / temp;
  ilbd = -i;
  }
  if(subd*temp > bdata->su[i] - bdata->xopt[i]) {
  subd = fmax(sumin, (bdata->su[i] - bdata->xopt[i]) / temp);
  iubd = i;
  }
  } else if(temp<0.0) {
  if(slbd*temp > bdata->su[i] - bdata->xopt[i]) {
  slbd = (bdata->su[i] - bdata->xopt[i]) / temp;
  ilbd = i;
  }
  if(subd*temp < bdata->sl[i] - bdata->xopt[i]) {
  subd = fmax(sumin, (bdata->sl[i] - bdata->xopt[i]) / temp);
  iubd = -i;
  }
  }
  }
 
  /* Seek a large modulus of the KNEW-th Lagrange function when the index
  of the other interpolation point on the line through XOPT is KNEW. */
  if(k==bdata->knew-1) {
  diff = dderiv - 1.0;
  step = slbd; vlag = slbd * (dderiv - slbd * diff);
  isbd = ilbd; temp = subd * (dderiv - subd * diff);
  if(fabs(temp) > fabs(vlag)) {
  step = subd; vlag = temp; isbd = iubd;
  }
  tempd = 0.5 * dderiv;
  tempa = tempd - diff * slbd;
  tempb = tempd - diff * subd;
  if(tempa*tempb < 0.0) {
  temp = tempd*tempd/diff;
  if(fabs(temp) > fabs(vlag)) {step=tempd/diff; vlag=temp; isbd=0;}
  }
 
  } else {
  /* Search along each of the other lines through XOPT and another point. */
  step = slbd; vlag = slbd * (1.0 - slbd);
  isbd = ilbd; temp = subd * (1.0 - subd);
  if(fabs(temp) > fabs(vlag)) {step=subd; vlag=temp; isbd=iubd;}
  if(subd>0.5 && fabs(vlag)<0.25) {step=0.5; vlag=0.25; isbd=0;}
  vlag*=dderiv;
  }
 
  /* Calculate PREDSQ for the current line search and maintain PRESAV. */
  temp = step*(1.0-step)*distsq;
  predsq = vlag*vlag*(vlag*vlag + ha*temp*temp);
  if(predsq>presav) {presav=predsq; ksav=k; stpsav=step; ibdsav=isbd;}
  }
 
  /* Construct XNEW in a way that satisfies the bound constraints exactly. */
  for(i=0; i<bdata->n; i++) {
  temp=bdata->xopt[i]+stpsav*(bdata->xpt[ksav+i*bdata->npt]-bdata->xopt[i]);
  d2=fmin(bdata->su[i],temp);
  bdata->xnew[i] = fmax(bdata->sl[i],d2);
  }
  if(ibdsav<0) bdata->xnew[-ibdsav]=bdata->sl[-ibdsav];
  if(ibdsav>0) bdata->xnew[ibdsav]=bdata->su[ibdsav];
 
 
  /* Prepare for the iterative method that assembles the constrained Cauchy
  step in CCSTEP. The sum of squares of the fixed components of CCSTEP is
  formed in WFIXSQ, and the free components of CCSTEP are set to BIGSTP. */
  bigstp = bdata->adelt + bdata->adelt;
  iflag=0;
  do {
  wfixsq = ggfree = 0.0;
  for(i=0; i<bdata->n; i++) {
  bdata->ccstep[i]=0.0;
  tempa = fmin(bdata->xopt[i] - bdata->sl[i], bdata->glag[i]);
  tempb = fmax(bdata->xopt[i] - bdata->su[i], bdata->glag[i]);
 
 /*
  // Removed again 2012-05-15 since now these do not have any effect
  if(fabs(tempa)<1.0E-20) tempa=0.0; // These 2 lines added by VO 2012-05-11
  if(fabs(tempb)<1.0E-20) tempb=0.0; // to prevent huge nr of function evals
 */
 
  if(tempa>0.0 || tempb<0.0) {
  bdata->ccstep[i]=bigstp;
  d2=bdata->glag[i]*bdata->glag[i]; if(isfinite(d2)) ggfree+=d2;
  }
  }
  //if(ggfree==0.0) {bdata->cauchy=0.0; return;}
  // Added isfinite test by VO 2012-09-16
  if(!isfinite(ggfree) || ggfree==0.0) {bdata->cauchy=0.0; return;}
 
  /* Investigate whether more components of CCSTEP can be fixed. */
  do {
  //temp = bdata->adelt * bdata->adelt - wfixsq;
  temp=fma(bdata->adelt, bdata->adelt, -wfixsq);
  if(temp>0.0) {
  wsqsav=wfixsq; step=sqrt(temp/ggfree);
  // This test added by VO 2012-05-24
  if(isnan(step)) {bdata->cauchy=0.0; return;}
  ggfree=0.0;
  for(i=0; i<bdata->n; i++) {
  if(bdata->ccstep[i]==bigstp) {
  //d2 = bdata->xopt[i] - step*bdata->glag[i];
  d2=fma(bdata->glag[i], -step, bdata->xopt[i]);
  if(d2 <= bdata->sl[i]) {
  bdata->ccstep[i] = bdata->sl[i] - bdata->xopt[i];
  wfixsq+=bdata->ccstep[i]*bdata->ccstep[i];
  } else if(d2 >= bdata->su[i]) {
  bdata->ccstep[i] = bdata->su[i] - bdata->xopt[i];
  wfixsq+=bdata->ccstep[i]*bdata->ccstep[i];
  } else {
  ggfree+=bdata->glag[i]*bdata->glag[i];
  }
  }
  }
 
  }
 #if(0) // original code
  } while(temp>0.0 && wfixsq>wsqsav && ggfree>0.0);
 #else // Changed by VO
  //} while(wfixsq-wsqsav>1.0E-12 && ggfree>1.0E-12);
  // Change by VO 2012-06-03
  //} while(wfixsq-wsqsav>1.0E-30 && ggfree>1.0E-30);
  // 2012-06-04 by VO: added tests to prevent looping forever in 32-bit Win7
  } while(isfinite(ggfree) && isfinite(wfixsq) && isfinite(wsqsav) &&
  // wfixsq-wsqsav>1.0E-30 && ggfree>1.0E-30 && temp>0.0);
  // Changed limits by VO 2012-09-16
  wfixsq-wsqsav>1.0E-50 && ggfree>1.0E-50 && temp>0.0);
 #endif
 
  /* Set the remaining free components of CCSTEP and all components of XALT,
  except that CCSTEP may be scaled later. */
  for(i=0, gw=0.0; i<bdata->n; i++) {
  if(bdata->ccstep[i]==bigstp) {
  bdata->ccstep[i] = -step*bdata->glag[i];
  d2=fmin(bdata->su[i], bdata->xopt[i]+bdata->ccstep[i]);
  bdata->xalt[i]=fmax(bdata->sl[i], d2);
  } else if(bdata->ccstep[i]==0.0) {
  bdata->xalt[i]=bdata->xopt[i];
  } else if(bdata->glag[i]>0.0) {
  bdata->xalt[i]=bdata->sl[i];
  } else {
  bdata->xalt[i]=bdata->su[i];
  }
  gw += bdata->glag[i]*bdata->ccstep[i];
  }
 
  /* Set CURV to the curvature of the KNEW-th Lagrange function along CCSTEP.
  Scale CCSTEP by a factor less than one if that can reduce the modulus of
  the Lagrange function at XOPT+CCSTEP. Set CAUCHY to the final value of
  the square of this function. */
  for(k=0, curv=0.0; k<bdata->npt; k++) {
  for(j=0, temp=0.0; j<bdata->n; j++)
  temp+=bdata->xpt[k + j*bdata->npt] * bdata->ccstep[j];
  curv += bdata->hcol[k]*temp*temp;
  }
  if(iflag==1) curv=-curv;
  if(curv>-gw && curv<-(1.0+M_SQRT2)*gw) {
  scale = -gw/curv;
  for(i=0; i<bdata->n; i++) {
  //temp = bdata->xopt[i] + scale*bdata->ccstep[i];
  temp = fma(scale, bdata->ccstep[i], bdata->xopt[i]);
  d2=fmin(bdata->su[i], temp);
  bdata->xalt[i]=fmax(bdata->sl[i], d2);
  }
 
  d1=0.5*gw*scale;
  } else {
  d1=fma(0.5, curv, gw); //d1=gw+0.5*curv;
  }
  bdata->cauchy=d1*d1;
 
  /* If IFLAG is zero, then XALT is calculated as before after reversing
  the sign of GLAG. Thus two XALT vectors become available. The one that
  is chosen is the one that gives the larger value of CAUCHY. */
  if(iflag==0) {
  for(i=0; i<bdata->n; i++) {
  bdata->glag[i]=-bdata->glag[i];
  bdata->ccstep[bdata->n+i]=bdata->xalt[i];
  }
  csave=bdata->cauchy; iflag=1;
  } else {
  break;
  }
  } while(1);
  if(csave > bdata->cauchy) {
  for(i=0; i<bdata->n; i++) bdata->xalt[i]=bdata->ccstep[bdata->n+i];
  bdata->cauchy=csave;
  }
  return;
 } /* bobyqa_altmov() */
 /******************************************************************************/
 
 /******************************************************************************/
 bobyqa_result bobyqa_prelim(
  bobyqa_data *bdata
 ) {
  bdata->prelim_nr++;
  if(bdata->verbose>5) {printf("bobyqa_prelim()\n"); fflush(stdout);}
 
  double f, d1, d2;
  int i, j, k, ih, np, nfm;
  int nfx, ipt=0, jpt=0;
  double fbeg, diff, temp, recip, stepa, stepb;
  int itemp;
  double rhosq, SQRT_HALF;
  int nf;
 
  /* Function Body */
  rhosq = bdata->rhobeg * bdata->rhobeg;
  recip = 1.0 / rhosq;
  np = bdata->n + 1;
  bdata->kopt=0;
  stepa=stepb=fbeg=0.0;
  jpt=ipt=0;
 
 
  /* Set XBASE to the initial vector of variables, and set the initial
  elements of XPT, BMAT, HQ, PQ and ZMAT to zero. */
  for(j=0; j<bdata->n; j++) {
  bdata->xbase[j]=bdata->x[j];
  for(k=0; k<bdata->npt; k++) bdata->xpt[k+j*bdata->npt]=0.0;
  for(i=0; i<bdata->ndim; i++) bdata->bmat[i+j*bdata->ndim]=0.0;
  }
  for(ih=0; ih<bdata->n*np/2; ih++) bdata->hq[ih]=0.0;
  for(k=0; k<bdata->npt; k++) {
  bdata->pq[k]=0.0;
  for(j=0; j<bdata->npt-np; j++) bdata->zmat[k+j*bdata->npt]=0.0;
  }
 
  /* Begin the initialization procedure. NF becomes one more than the number
  of function values so far. The coordinates of the displacement of the
  next initial interpolation point from XBASE are set in XPT(NF+1,.). */
  nf=0; SQRT_HALF=sqrt(0.5);
  do {
  nfm=nf; nfx=nf-bdata->n; nf++;
  if(nfm<=2*bdata->n) {
  if(nfm>=1 && nfm<=bdata->n) {
  stepa=bdata->rhobeg;
  if(bdata->su[nfm-1]==0.0) stepa=-stepa;
  bdata->xpt[nf-1+(nfm-1)*bdata->npt]=stepa;
  } else if (nfm > bdata->n) {
  stepa = bdata->xpt[nf-1 - bdata->n + (nfx-1)*bdata->npt];
  stepb = -bdata->rhobeg;
  if(bdata->sl[nfx-1]==0.0) {
  stepb=fmin(2.0*bdata->rhobeg, bdata->su[nfx-1]);}
  if(bdata->su[nfx-1]==0.0) {
  stepb=fmax(-2.0*bdata->rhobeg, bdata->sl[nfx-1]);}
  bdata->xpt[nf-1 + (nfx-1)*bdata->npt] = stepb;
  }
  } else {
  itemp=(nfm-np)/bdata->n;
  jpt=nfm-itemp*bdata->n-bdata->n; ipt=jpt+itemp;
  if(ipt > bdata->n) {itemp=jpt; jpt=ipt-bdata->n; ipt=itemp;}
  bdata->xpt[nf-1+(ipt-1)*bdata->npt]= bdata->xpt[ipt+(ipt-1)*bdata->npt];
  bdata->xpt[nf-1+(jpt-1)*bdata->npt]= bdata->xpt[jpt+(jpt-1)*bdata->npt];
  }
 
  /* Calculate the next value of F. The least function value so far and
  its index are required. */
  for(j=0; j<bdata->n; j++) {
  d2 = bdata->xbase[j] + bdata->xpt[nf-1 + j*bdata->npt];
  d1 = fmax(bdata->xl[j],d2);
  bdata->x[j] = fmin(d1,bdata->xu[j]);
  if(bdata->xpt[nf-1 + j*bdata->npt] == bdata->sl[j])
  bdata->x[j]=bdata->xl[j];
  else if(bdata->xpt[nf-1 + j*bdata->npt] == bdata->su[j])
  bdata->x[j]=bdata->xu[j];
  }
  /* Update the full parameter list for objf() */
  f=bobyqa_x_funcval(bdata, bdata->x);
  bdata->fval[nf-1]=f;
  if(nf==1) {fbeg=f; bdata->kopt=1;}
  else if(f<bdata->fval[bdata->kopt-1]) bdata->kopt=nf;
 
  /* Set the nonzero initial elements of BMAT and the quadratic model in the
  cases when NF is at most 2*N+1. If NF exceeds N+1, then the positions
  of the NF-th and (NF-N)-th interpolation points may be switched, in
  order that the function value at the first of them contributes to the
  off-diagonal second derivative terms of the initial quadratic model. */
 
  if(nf<=2*bdata->n+1) {
  if(nf>=2 && nf<=bdata->n+1) {
  bdata->gopt[nfm-1] = (f-fbeg)/stepa;
  if(bdata->npt < nf+bdata->n) {
  bdata->bmat[(nfm-1)*bdata->ndim] = -1.0/stepa;
  bdata->bmat[(nf-1) + (nfm-1)*bdata->ndim] = 1.0/stepa;
  bdata->bmat[bdata->npt + (nfm-1) + (nfm-1)*bdata->ndim] = -0.5*rhosq;
  }
  } else if(nf>=bdata->n+2) {
  ih = nfx*(nfx+1)/2;
  temp = (f-fbeg)/stepb; diff=stepb-stepa;
  bdata->hq[ih-1] = 2.0*(temp-bdata->gopt[nfx-1])/diff;
  bdata->gopt[nfx-1] = (bdata->gopt[nfx-1]*stepb - temp*stepa) / diff;
  if(stepa*stepb < 0.0) {
  if(f < bdata->fval[nf-1 - bdata->n]) {
  bdata->fval[nf-1] = bdata->fval[nf-1 - bdata->n];
  bdata->fval[nf-1 - bdata->n] = f;
  if(bdata->kopt==nf) bdata->kopt=nf-bdata->n;
  bdata->xpt[nf-1 - bdata->n + (nfx-1)*bdata->npt] = stepb;
  bdata->xpt[nf-1 + (nfx-1)*bdata->npt] = stepa;
  }
  }
  bdata->bmat[(nfx-1)*bdata->ndim] = -(stepa+stepb)/(stepa*stepb);
  bdata->bmat[(nf-1) + (nfx-1)*bdata->ndim] =
  -0.5/bdata->xpt[nf-1 - bdata->n + (nfx-1)*bdata->npt];
  bdata->bmat[nf-1 - bdata->n + (nfx-1)*bdata->ndim] =
  -bdata->bmat[(nfx-1)*bdata->ndim] -
  bdata->bmat[nf-1 + (nfx-1)*bdata->ndim];
  bdata->zmat[(nfx-1)*bdata->npt] = M_SQRT2/(stepa*stepb);
  bdata->zmat[nf-1 + (nfx-1)*bdata->npt] = SQRT_HALF/rhosq;
  bdata->zmat[nf-1 - bdata->n + (nfx-1)*bdata->npt] =
  -bdata->zmat[(nfx-1)*bdata->npt] -
  bdata->zmat[nf-1 + (nfx-1)*bdata->npt];
  }
 
  } else {
  /* Set the off-diagonal second derivatives of the Lagrange functions and
  the initial quadratic model. */
  ih = ipt*(ipt-1)/2 + jpt;
  bdata->zmat[(nfx-1)*bdata->npt] = recip;
  bdata->zmat[nf-1 + (nfx-1)*bdata->npt] = recip;
  bdata->zmat[ipt + (nfx-1)*bdata->npt] = -recip;
  bdata->zmat[jpt + (nfx-1)*bdata->npt] = -recip;
  temp= bdata->xpt[nf - 1 + (ipt-1)*bdata->npt]
  * bdata->xpt[nf - 1 + (jpt-1)*bdata->npt];
  bdata->hq[ih-1] =
  (fbeg - bdata->fval[ipt] - bdata->fval[jpt] + f) / temp;
 
  }
  //bdata->nevals=nf; // VO: added 2012-05-10, removed 2012-09-16
  if(f < bdata->minf_max) {
  //printf("BOBYQA_MINF_MAX_REACHED\n");
  return BOBYQA_MINF_MAX_REACHED;
  } else if((bdata->maxeval>0) && (bdata->nevals>=bdata->maxeval)) {
  //printf("BOBYQA_MAXEVAL_REACHED\n");
  return BOBYQA_MAXEVAL_REACHED;
  }
  } while (nf<bdata->npt);
 
  return BOBYQA_SUCCESS;
 } /* bobyqa_prelim() */
 /******************************************************************************/
 
 /******************************************************************************/
 // RESCUE
 bobyqa_result bobyqa_rescue(bobyqa_data *bdata)
 {
  bdata->rescue_nr++;
  // rescue() is called very seldomly, therefore tell it always in verbose mode
  if(bdata->verbose>0) {printf("bobyqa_rescue()\n"); fflush(stdout);}
 
  double d1, d2, f;
  int i, j, k, ih, jp, ip, iq, np, iw;
  double xp=0.0, xq=0.0, den;
  int ihp=1;
  int ihq, jpn, kpt, kold;
  double sum, diff, winc, temp, bsum;
  int nrem;
  double hdiag, fbase, sfrac, vquad, sumpq;
  double dsqmin=0.0, distsq, vlmxsq;
  /* PTSAUX is also a working space array with length 2*N. For J=1,2,...,N,
  PTSAUX(1,J) and PTSAUX(2,J) specify the two positions of provisional
  interpolation points when a nonzero step is taken along e_J (the J-th
  coordinate direction) through XBASE+XOPT, as specified below.
  Usually these steps have length DELTA, but other lengths are chosen
  if necessary in order to satisfy the given bounds on the variables. */
  double *ptsaux;
  /* PTSID is also a working space array. It has NPT components that denote
  provisional new positions of the original interpolation points, in
  case changes are needed to restore the linear independence of the
  interpolation conditions. The K-th point is a candidate for change
  if and only if PTSID(K) is nonzero. In this case let p and q be the
  int parts of PTSID(K) and (PTSID(K)-p) multiplied by N+1. If p
  and q are both positive, the step from XBASE+XOPT to the new K-th
  interpolation point is PTSAUX(1,p)*e_p + PTSAUX(1,q)*e_q. Otherwise
  the step is PTSAUX(1,p)*e_p or PTSAUX(2,q)*e_q in the cases q=0 or
  p=0, respectively. */
  double *ptsid;
  /* Working space of length NDIM+NPT. */
  double *w;
 
 
  /* Allocate local memory; no need to preallocate */
  ptsaux=malloc(2*bdata->n*sizeof(double));
  ptsid=malloc(bdata->npt*sizeof(double));
  w=malloc((bdata->ndim*bdata->npt)*sizeof(double));
 
  /* Function Body */
  np = bdata->n + 1;
  sfrac = 0.5 / (double)np;
 
  /* Shift the interpolation points so that XOPT becomes the origin, and set
  the elements of ZMAT to zero. The value of SUMPQ is required in the
  updating of HQ below. The squares of the distances from XOPT to the
  other interpolation points are set at the end of W. Increments of WINC
  may be added later to these squares to balance the consideration of
  the choice of point that is going to become current. */
  sumpq = winc = 0.0;
  for(k=0; k<bdata->npt; k++) {
  for(j=0, distsq=0.0; j<bdata->n; j++) {
  bdata->xpt[k + j*bdata->npt] -= bdata->xopt[j];
  distsq += bdata->xpt[k + j*bdata->npt] * bdata->xpt[k + j*bdata->npt];
  }
  sumpq += bdata->pq[k];
  w[bdata->ndim + k] = distsq;
  winc=fmax(winc, distsq);
  for(j=0; j<bdata->nptm; j++) bdata->zmat[k + j*bdata->npt] = 0.0;
  }
 
  /* Update HQ so that HQ and PQ define the second derivatives of the model
  after XBASE has been shifted to the trust region centre. */
  ih = 0;
  for(j=0; j<bdata->n; j++) {
  w[j] = 0.5*sumpq*bdata->xopt[j];
  for(k=0; k<bdata->npt; k++)
  w[j] += bdata->pq[k] * bdata->xpt[k + j*bdata->npt];
  for(i=0; i<=j; i++, ih++)
  bdata->hq[ih] += w[i]*bdata->xopt[j] + w[j]*bdata->xopt[i];
  }
 
  /* Shift XBASE, SL, SU and XOPT. Set the elements of BMAT to zero, and
  also set the elements of PTSAUX. */
  for(j=0; j<bdata->n; j++) {
  bdata->xbase[j] += bdata->xopt[j];
  bdata->sl[j] -= bdata->xopt[j];
  bdata->su[j] -= bdata->xopt[j];
  bdata->xopt[j] = 0.0;
  ptsaux[j] = fmin(bdata->delta, bdata->su[j]);
  ptsaux[j+bdata->n] = fmax((-bdata->delta), bdata->sl[j]);
  if(ptsaux[j] + ptsaux[j+bdata->n] < 0.0) {
  temp = ptsaux[j];
  ptsaux[j] = ptsaux[j+bdata->n];
  ptsaux[j+bdata->n] = temp;
  }
  if(fabs(ptsaux[j+bdata->n]) < 0.5*(fabs(ptsaux[j])))
  ptsaux[j+bdata->n] = 0.5*ptsaux[j];
  for(i=0; i<bdata->ndim; ++i) bdata->bmat[i + j*bdata->ndim] = 0.0;
  }
  fbase = bdata->fval[bdata->kopt-1];
 
  /* Set the identifiers of the artificial interpolation points that are
  along a coordinate direction from XOPT, and set the corresponding
  nonzero elements of BMAT and ZMAT. */
  ptsid[0] = sfrac;
  for(j=0; j<bdata->n; j++) {
  jp = j + 1; jpn = jp + bdata->n;
  ptsid[jp] = (double)(j+1) + sfrac;
  if(jpn < bdata->npt) {
  ptsid[jpn] = (double)(j+1)/(double)(np+1) + sfrac;
  temp = 1.0 / (ptsaux[j] - ptsaux[j+bdata->n]);
  bdata->bmat[jp + j*bdata->ndim] = -temp + 1.0 / ptsaux[j];
  bdata->bmat[jpn + j*bdata->ndim] = temp + 1.0 / ptsaux[j+bdata->n];
  bdata->bmat[j*bdata->ndim + 1] =
  -bdata->bmat[jp + j*bdata->ndim] - bdata->bmat[jpn + j*bdata->ndim];
  bdata->zmat[j*bdata->npt] = M_SQRT2/fabs(ptsaux[j] * ptsaux[j+bdata->n]);
  bdata->zmat[jp + j*bdata->npt] =
  bdata->zmat[j*bdata->npt] * ptsaux[j+bdata->n] * temp;
  bdata->zmat[jpn + j*bdata->npt] =
  -bdata->zmat[j*bdata->npt] * ptsaux[j] * temp;
  } else {
  bdata->bmat[j*bdata->ndim] = -1.0 / ptsaux[j];
  bdata->bmat[jp + j*bdata->ndim] = 1.0 / ptsaux[j];
  bdata->bmat[j + bdata->npt + j*bdata->ndim] = -0.5*(ptsaux[j]*ptsaux[j]);
  }
  }
 
  /* Set any remaining identifiers with their nonzero elements of ZMAT. */
  if (bdata->npt >= bdata->n + np) {
  for(k=2*np-1; k<bdata->npt; k++) {
  /* we end up here only when user has given higher NPT than is
  usually required */
  iw = (int) ( ((double)(k+1-np)-0.5) / (double)bdata->n );
  ip = k+1 - np - iw*bdata->n;
  iq = ip + iw;
  if(iq>bdata->n) iq-=bdata->n;
  ptsid[k] = (double)ip + (double)iq/(double)np + sfrac;
  temp = 1.0 / (ptsaux[ip]*ptsaux[iq]);
  bdata->zmat[(k-np)*bdata->npt] = temp;
  bdata->zmat[ip + (k-np)*bdata->npt] = -temp;
  bdata->zmat[iq + (k-np)*bdata->npt] = -temp;
  bdata->zmat[k + (k-np)*bdata->npt] = temp;
  }
  }
  nrem=bdata->npt; kold=1; bdata->knew=bdata->kopt;
 
  do {
  /* Reorder the provisional points in the way that exchanges PTSID(KOLD)
  with PTSID(KNEW). */
  for(j=0; j<bdata->n; j++) {
  temp = bdata->bmat[kold-1 + j*bdata->ndim];
  bdata->bmat[kold-1 + j*bdata->ndim] =
  bdata->bmat[bdata->knew-1 + j*bdata->ndim];
  bdata->bmat[bdata->knew-1 + j*bdata->ndim]=temp;
  }
  for(j=0; j<bdata->nptm; j++) {
  temp = bdata->zmat[kold-1 + j*bdata->npt];
  bdata->zmat[kold-1 + j*bdata->npt] =
  bdata->zmat[bdata->knew-1 + j*bdata->npt];
  bdata->zmat[bdata->knew-1 + j*bdata->npt] = temp;
  }
  ptsid[kold-1] = ptsid[bdata->knew-1];
  ptsid[bdata->knew-1]=0.0;
  w[bdata->ndim + bdata->knew-1]=0.0;
  --nrem;
  if(bdata->knew != bdata->kopt) {
  temp = bdata->vlag[kold-1];
  bdata->vlag[kold-1] = bdata->vlag[bdata->knew-1];
  bdata->vlag[bdata->knew-1] = temp;
 
  /* Update the BMAT and ZMAT matrices so that the status of the KNEW-th
  interpolation point can be changed from provisional to original. The
  branch to label 350 occurs if all the original points are reinstated. */
  bobyqa_update(bdata);
  if(nrem==0) {free(ptsaux); free(ptsid); free(w); return BOBYQA_SUCCESS;}
  /* The nonnegative values of W(NDIM+K) are required in the search below. */
  for(k=0; k<bdata->npt; k++)
  w[k+bdata->ndim] = fabs(w[k+bdata->ndim]);
  }
 
  /* Pick the index KNEW of an original interpolation point that has not
  yet replaced one of the provisional interpolation points, giving
  attention to the closeness to XOPT and to previous tries with KNEW. */
  while(1) {
  dsqmin=0.0;
  for(k=0; k<bdata->npt; k++) {
  if(w[bdata->ndim+k] > 0.0) {
  if(dsqmin==0.0 || w[bdata->ndim+k]<dsqmin) {
  bdata->knew=k+1; dsqmin=w[bdata->ndim+k];}
  }
  }
  if(dsqmin==0.0) break;
 
  /* Form the W-vector of the chosen original interpolation point. */
  for(j=0; j<bdata->n; j++)
  w[bdata->npt+j] = bdata->xpt[bdata->knew-1 + j*bdata->npt];
 
 
  for(k=0; k<bdata->npt; k++) {
  sum=0.0;
  if(k==bdata->kopt-1) { // then nothing
  } else if(ptsid[k]==0.0) {
  for(j=0; j<bdata->n; j++)
  sum += w[bdata->npt+j]*bdata->xpt[k + j*bdata->npt];
  } else {
  ip = (int)ptsid[k];
  if(ip>0) sum = w[bdata->npt + ip-1] * ptsaux[ip-1]; // ok
  iq = (int) ( (double)np*ptsid[k] - (double)(ip*np)); // ok
  if(iq>0) {
  iw=0; if(ip==0) iw=1;
  sum += w[iq-1 + bdata->npt] * ptsaux[iq-1 + iw*bdata->n];
  }
  }
  w[k] = 0.5*sum*sum;
  }
  /* Calculate VLAG and BETA for the required updating of the H matrix if
  XPT(KNEW,.) is reinstated in the set of interpolation points. */
  for(k=0; k<bdata->npt; k++) {
  for(j=0, sum=0.0; j<bdata->n; j++)
  sum += bdata->bmat[k + j*bdata->ndim] * w[bdata->npt + j];
  bdata->vlag[k] = sum;
  }
  bdata->beta = 0.0;
  for(j=0; j<bdata->nptm; j++) {
  for(k=0, sum=0.0; k<bdata->npt; k++)
  sum += bdata->zmat[k + j*bdata->npt] * w[k];
  bdata->beta -= sum*sum;
  for(k=0; k<bdata->npt; k++)
  bdata->vlag[k] += sum * bdata->zmat[k + j*bdata->npt];
  }
  bsum = distsq = 0.0;
  for(j=0; j<bdata->n; j++) {
  for(k=0, sum=0.0; k<bdata->npt; k++)
  sum += bdata->bmat[k + j*bdata->ndim] * w[k];
  jp = j + bdata->npt;
  bsum += sum * w[jp];
  for(ip=bdata->npt; ip<bdata->ndim; ip++)
  sum += bdata->bmat[ip + j*bdata->ndim] * w[ip];
  bsum += sum * w[jp];
  bdata->vlag[jp] = sum;
  d1 = bdata->xpt[bdata->knew-1 + j*bdata->npt]; distsq += d1*d1;
  }
 
  bdata->beta += 0.5*distsq*distsq - bsum;
  bdata->vlag[bdata->kopt-1] += 1.0;
 
  /* KOLD is set to the index of the provisional interpolation point that is
  going to be deleted to make way for the KNEW-th original interpolation
  point. The choice of KOLD is governed by the avoidance of a small value
  of the denominator in the updating calculation of UPDATE. */
  bdata->denom = vlmxsq = 0.0;
  for(k=0; k<bdata->npt; k++) {
  if(ptsid[k] != 0.0) {
  for(j=0, hdiag=0.0; j<bdata->nptm; j++)
  hdiag += bdata->zmat[k + j*bdata->npt] * bdata->zmat[k + j*bdata->npt];
  den = bdata->beta*hdiag + bdata->vlag[k]*bdata->vlag[k];
  if(den > bdata->denom) {kold=k+1; bdata->denom=den;}
  }
  vlmxsq = fmax(vlmxsq, bdata->vlag[k]*bdata->vlag[k]);
  }
  if(bdata->denom > 0.01*vlmxsq) break;
  w[bdata->ndim + bdata->knew-1] = -w[bdata->ndim + bdata->knew-1] - winc;
  } // end of while
  } while(dsqmin!=0.0); // end of main loop
 
  /* When this point is reached, all the final positions of the interpolation
  points have been chosen although any changes have not been included yet
  in XPT. Also the final BMAT and ZMAT matrices are complete, but, apart
  from the shift of XBASE, the updating of the quadratic model remains to
  be done. The following cycle through the new interpolation points begins
  by putting the new point in XPT(KPT,.) and by setting PQ(KPT) to zero,
  except that a RETURN occurs if MAXFUN prohibits another value of F. */
  for(kpt=0; kpt<bdata->npt; kpt++) if((ptsid[kpt]!=0.0)) {
 
  if((bdata->maxeval>0) && (bdata->nevals>=bdata->maxeval)) {
  free(ptsaux); free(ptsid); free(w); return BOBYQA_MAXEVAL_REACHED;}
 
  ih = 0;
  for(j=0; j<bdata->n; j++) {
  w[j] = bdata->xpt[kpt + j*bdata->npt];
  bdata->xpt[kpt + j*bdata->npt] = 0.0;
  temp = bdata->pq[kpt] * w[j];
  for(i=0; i<=j; i++, ih++) bdata->hq[ih] += temp*w[i];
  }
  bdata->pq[kpt] = 0.0;
  ip = (int) ptsid[kpt];
  iq = (int) ((double)np * ptsid[kpt] - (double)(ip * np));
  if(ip > 0) {
  xp = ptsaux[ip-1];
  bdata->xpt[kpt + (ip-1)*bdata->npt] = xp;
  }
  if(iq > 0) {
  xq = ptsaux[iq-1];
  if(ip==0) xq = ptsaux[iq-1 + bdata->n];
  bdata->xpt[kpt + (iq-1)*bdata->npt] = xq;
  }
 
  /* Set VQUAD to the value of the current model at the new point. */
  vquad = fbase;
  if(ip > 0) {
  ihp = (ip + ip*ip) / 2;
  vquad += xp * (bdata->gopt[ip-1] + 0.5*xp*bdata->hq[ihp-1]);
  }
  if(iq > 0) {
  ihq = (iq + iq*iq) / 2;
  vquad += xq * (bdata->gopt[iq-1] + 0.5*xq*bdata->hq[ihq-1]);
  if(ip > 0) {
  if(ihp>=ihq) iw=ihp; else iw=ihq;
  iw-=abs(ip-iq);
  vquad += xp*xq*bdata->hq[iw-1];
  }
  }
  for(k=0; k<bdata->npt; k++) {
  temp=0.0;
  if(ip > 0) temp += xp * bdata->xpt[k + (ip-1)*bdata->npt];
  if(iq > 0) temp += xq * bdata->xpt[k + (iq-1)*bdata->npt];
  vquad += 0.5 * bdata->pq[k] * temp*temp;
  }
 
  /* Calculate F at the new interpolation point, and set DIFF to the factor
  that is going to multiply the KPT-th Lagrange function when the model
  is updated to provide interpolation to the new function value. */
  for(i=0; i<bdata->n; i++) {
  d2 = bdata->xbase[i] + bdata->xpt[kpt + i*bdata->npt];
  d1 = fmax(bdata->xl[i], d2);
  w[i] = fmin(d1, bdata->xu[i]);
  if(bdata->xpt[kpt + i*bdata->npt] == bdata->sl[i]) w[i] = bdata->xl[i];
  if(bdata->xpt[kpt + i*bdata->npt] == bdata->su[i]) w[i] = bdata->xu[i];
  }
 
  /* Update the full parameter list for objf() */
  f=bobyqa_x_funcval(bdata, w);
  bdata->fval[kpt] = f;
 
  if(f < bdata->fval[bdata->kopt-1]) bdata->kopt = kpt+1;
  if(f < bdata->minf_max) {
  free(ptsaux); free(ptsid); free(w); return BOBYQA_MINF_MAX_REACHED;}
  else if((bdata->maxeval>0) && (bdata->nevals>=bdata->maxeval)) {
  free(ptsaux); free(ptsid); free(w); return BOBYQA_MAXEVAL_REACHED;}
  diff = f - vquad;
 
  /* Update the quadratic model. The RETURN from the subroutine occurs when
  all the new interpolation points are included in the model. */
 
  for(i=0; i<bdata->n; i++)
  bdata->gopt[i] += diff * bdata->bmat[kpt + i*bdata->ndim];
  for(k=0; k<bdata->npt; k++) {
  for(j=0, sum=0.0; j<bdata->nptm; j++)
  sum += bdata->zmat[k + j*bdata->npt] * bdata->zmat[kpt + j*bdata->npt];
  temp = diff * sum;
  if(ptsid[k]==0.0) {
  bdata->pq[k] += temp;
  } else {
  ip = (int)ptsid[k];
  iq = (int) ((double)np*ptsid[k] - (double)(ip*np));
  ihq = (iq*iq + iq) / 2;
  if(ip == 0) {
  d1=ptsaux[iq-1 + bdata->n];
  bdata->hq[ihq-1] += temp * (d1*d1);
  } else {
  ihp = (ip*ip + ip) / 2;
  d1 = ptsaux[ip-1];
  bdata->hq[ihp-1] += temp * (d1*d1);
  if(iq > 0) {
  d1 = ptsaux[iq-1];
  bdata->hq[ihq-1] += temp * (d1*d1);
  if(ihp>=ihq) iw=ihp; else iw=ihq;
  iw-=abs(iq-ip); // iw = max(ihp,ihq) - abs(iq-ip);
  bdata->hq[iw-1] += temp * ptsaux[ip-1] * ptsaux[iq-1];
  }
  }
  }
  }
  ptsid[kpt] = 0.0;
  }
 
  free(ptsaux); free(ptsid); free(w);
  return BOBYQA_SUCCESS;
 } /* bobyqa_rescue() */
 /******************************************************************************/
 
 /******************************************************************************/
 // TRSBOX
 void trsbox_s_multiply(
  bobyqa_data *bdata
 ) {
  int i, j, k, ih=0;
  double temp;
 
  for(j=0; j<bdata->n; j++) {
  bdata->hs[j]=0.0;
  for(i=0; i<=j; i++, ih++) {
  if(i<j) bdata->hs[j]+=bdata->hq[ih]*bdata->s[i];
  bdata->hs[i]+=bdata->hq[ih]*bdata->s[j];
  }
  }
  for(k=0; k<bdata->npt; k++) if(bdata->pq[k]!=0.0) {
  for(j=0, temp=0.0; j<bdata->n; j++)
  temp+=bdata->xpt[k+j*bdata->npt]*bdata->s[j];
  temp*=bdata->pq[k];
  for(i=0; i<bdata->n; i++) bdata->hs[i]+=temp*bdata->xpt[k+i*bdata->npt];
  }
 }
 /******************************************************************************/
 void trsbox_set_xnew(
  bobyqa_data *bdata
 ) {
  int i;
  double d1, d2;
 
  for(i=0, bdata->dsq=0.0; i<bdata->n; i++) {
  if(bdata->xbdi[i]==-1.0) bdata->xnew[i]=bdata->sl[i];
  else if(bdata->xbdi[i]==1.0) bdata->xnew[i]=bdata->su[i];
  else {
  d2=bdata->xopt[i]+bdata->dtrial[i]; d1=fmin(d2, bdata->su[i]);
  bdata->xnew[i]=fmax(d1, bdata->sl[i]);
  }
  bdata->dtrial[i]=bdata->xnew[i]-bdata->xopt[i];
  bdata->dsq+=bdata->dtrial[i]*bdata->dtrial[i];
  }
 }
 /******************************************************************************/
 
 /******************************************************************************/
 void bobyqa_trsbox(
  bobyqa_data *bdata
 ) {
  bdata->trsbox_nr++;
  if(bdata->verbose>5) {printf("trsbox()\n"); fflush(stdout);}
  int i, iu, iact, nact, isav, iterc, itermax, perp_altern=1;
  double ds, dhd, dhs, cth, shs, sth, ssq, beta, sdec=0.0, blen;
  double angt, qred, d1, d2;
  double temp, xsav=0.0, xsum, angbd, dredg=0.0, sredg;
  double resid, delsq, ggsav=0.0, tempa, tempb, redmax;
  double dredsq=0.0, redsav, gredsq=0.0, rednew;
  double rdprev=0.0, rdnext=0.0, stplen, stepsq;
 
 
  /* The sign of GOPT(I) gives the sign of the change to the I-th variable
  that will reduce Q from its value at XOPT. Thus XBDI(I) shows whether
  or not to fix the I-th variable at one of its bounds initially, with
  NACT being set to the number of fixed variables. D and GNEW are also
  set for the first iteration. DELSQ is the upper bound on the sum of
  squares of the free variables. QRED is the reduction in Q so far. */
  iterc=0; nact=0;
  for(i=0; i<bdata->n; i++) {
  bdata->xbdi[i] = 0.0;
  if(bdata->xopt[i]<=bdata->sl[i] && bdata->gopt[i]>=0.0)
  bdata->xbdi[i]=-1.0;
  else if(bdata->xopt[i]>=bdata->su[i] && bdata->gopt[i]<=0.0)
  bdata->xbdi[i]=1.0;
  if(bdata->xbdi[i]!=0.0) nact++;
  bdata->dtrial[i]=0.0;
  bdata->gnew[i]=bdata->gopt[i];
  }
  delsq = bdata->delta*bdata->delta;
  qred = 0.0;
  bdata->_crvmin = -1.0;
 
  /* Set the next search direction of the conjugate gradient method. It is
  the steepest descent direction initially and when the iterations are
  restarted because a variable has just been fixed by a bound, and of
  course the components of the fixed variables are zero. ITERMAX is an
  upper bound on the indices of the conjugate gradient iterations. */
  beta = 0.0;
  itermax = iterc + bdata->n - nact;
  while(1) {
  stepsq = 0.0;
  for(i=0; i<bdata->n; i++) {
  if(bdata->xbdi[i]!=0.0) bdata->s[i]=0.0;
  else if(beta==0.0) bdata->s[i]=-bdata->gnew[i];
  else bdata->s[i]=beta*bdata->s[i]-bdata->gnew[i];
  stepsq+=bdata->s[i]*bdata->s[i];
  }
  if(stepsq == 0.0) {
  trsbox_set_xnew(bdata); return;
  }
  if(beta==0.0) {gredsq=stepsq; itermax=iterc+bdata->n-nact;}
  if(gredsq*delsq <= qred*qred*1.0E-04) {
  trsbox_set_xnew(bdata); return;
  }
 
  /* Multiply the search direction by the second derivative matrix of Q and
  calculate some scalars for the choice of steplength. Then set BLEN to
  the length of the the step to the trust region boundary and STPLEN to
  the steplength, ignoring the simple bounds. */
  trsbox_s_multiply(bdata);
 
  resid=delsq; ds=shs=0.0;
  for(i=0; i<bdata->n; i++) if(bdata->xbdi[i]==0.0) {
  resid-=bdata->dtrial[i]*bdata->dtrial[i];
  ds+=bdata->s[i]*bdata->dtrial[i]; shs+=bdata->s[i]*bdata->hs[i];
  }
  // if(resid<=0.0) break;
  // Added isfinite test by VO 2012-09-16
  if(!isfinite(resid) || resid<=0.0) break;
  temp=sqrt(stepsq*resid + ds*ds);
  if(ds<0.0) blen=(temp-ds)/stepsq; else blen=resid/(temp+ds);
  stplen=blen; if(shs>0.0) {d1=blen; d2=gredsq/shs; stplen=fmin(d1, d2);}
 
  /* Reduce STPLEN if necessary in order to preserve the simple bounds,
  letting IACT be the index of the new constrained variable. */
  iact=0;
  for(i=0; i<bdata->n; i++) if(bdata->s[i]!=0.0) {
  xsum=bdata->xopt[i]+bdata->dtrial[i];
  if(bdata->s[i]>0.0) temp=(bdata->su[i]-xsum)/bdata->s[i];
  else temp=(bdata->sl[i]-xsum)/bdata->s[i];
  if(temp<stplen) {stplen=temp; iact=i+1;}
  }
 
  /* Update CRVMIN, GNEW and D. Set SDEC to the decrease that occurs in Q. */
  sdec=0.0;
  if(isfinite(stplen) && stplen>0.0) {
 // Changed to include isfinite test by VO 2012-09-16
 // if(stplen>0.0) {
 // if(stplen>1.0E-15) { // Changed by VO 2012-05-11 to reduce fevals
 // Returned back to original 2012-05-15 since now it seems to have no effect
 
  iterc++; temp=shs/stepsq;
  if(iact==0 && temp>0.0) {
  bdata->_crvmin=fmin(bdata->_crvmin, temp);
  if(bdata->_crvmin==-1.0) bdata->_crvmin=temp;
  }
  ggsav=gredsq; gredsq=0.0;
  for(i=0; i<bdata->n; i++) {
  bdata->gnew[i]+=stplen*bdata->hs[i];
  if(bdata->xbdi[i]==0.0) gredsq+=bdata->gnew[i]*bdata->gnew[i];
  bdata->dtrial[i]+=stplen*bdata->s[i];
  }
  d1=stplen*(ggsav-0.5*stplen*shs); sdec=fmax(d1,0.0); qred+=sdec;
  }
 
  /* Restart the conjugate gradient method if it has hit a new bound. */
  if(iact>0) {
  i=iact-1; nact++;
  if(bdata->s[i]<0.0) bdata->xbdi[i]=-1.0; else bdata->xbdi[i]=1.0;
  delsq-=bdata->dtrial[i]*bdata->dtrial[i];
  if(!isfinite(delsq) || delsq<=0.0) break; // Added isfinite 2012-09-16
  beta=0.0;
  continue;
  }
 
  /* If STPLEN is less than BLEN, then either apply another conjugate
  gradient iteration or RETURN. */
  if(stplen>=blen) break;
  if(iterc==itermax || sdec<=0.01*qred) {
  trsbox_set_xnew(bdata); return;
  }
  beta=gredsq/ggsav; if(!isfinite(beta)) beta=0.0; // Added isfinite 2012-09-16
  } // end of while
 
  bdata->_crvmin=0.0;
 
  while(1) {
  if(perp_altern==1) {
  /* Prepare for the alternative iteration by calculating some scalars
  and by multiplying the reduced D by the second derivative matrix of
  Q, where S holds the reduced D in the call of GGMULT. */
  if(nact>=bdata->n-1) {
  trsbox_set_xnew(bdata); return;
  }
  dredsq=dredg=gredsq=0.0;
  for(i=0; i<bdata->n; i++) {
  if(bdata->xbdi[i]==0.0) {
  dredsq+=bdata->dtrial[i]*bdata->dtrial[i];
  dredg+=bdata->dtrial[i]*bdata->gnew[i];
  gredsq+=bdata->gnew[i]*bdata->gnew[i]; bdata->s[i]=bdata->dtrial[i];
  } else {
  bdata->s[i]=0.0;
  }
  }
  trsbox_s_multiply(bdata);
  for(i=0; i<bdata->n; i++) bdata->hred[i]=bdata->hs[i];
  }
 
  /* Let the search direction S be a linear combination of the reduced D
  and the reduced G that is orthogonal to the reduced D. */
  iterc++;
  temp = gredsq*dredsq - dredg*dredg;
  if(!isfinite(temp) || temp<=qred*qred*1.0E-04) {// Added isfinite 2012-09-16
  trsbox_set_xnew(bdata); return;
  }
  temp = sqrt(temp);
  for(i=0; i<bdata->n; i++) {
  if(bdata->xbdi[i]==0.0)
  bdata->s[i]=(dredg*bdata->dtrial[i]-dredsq*bdata->gnew[i])/temp;
  else bdata->s[i]=0.0;
  }
  sredg=-temp;
 
  /* By considering the simple bounds on the variables, calculate an upper
  bound on the tangent of half the angle of the alternative iteration,
  namely ANGBD, except that, if already a free variable has reached a
  bound, there is a branch back to label 100 after fixing that variable. */
  angbd=1.0; iact=0;
  for(i=0; i<bdata->n; i++) if(bdata->xbdi[i]==0.0) {
  tempa=bdata->xopt[i]+bdata->dtrial[i]-bdata->sl[i];
  tempb=bdata->su[i]-bdata->xopt[i]-bdata->dtrial[i];
  if(tempa<=0.0) {nact++; bdata->xbdi[i]=-1.0; break;}
  else if(tempb<=0.0) {nact++; bdata->xbdi[i]=1.0; break;}
  d1=bdata->dtrial[i]; d2=bdata->s[i]; ssq=d1*d1+d2*d2;
  d1=bdata->xopt[i]-bdata->sl[i]; temp=ssq-d1*d1;
  if(temp>0.0) {
  temp=sqrt(temp)-bdata->s[i];
  if(angbd*temp>tempa) {angbd=tempa/temp; iact=i+1; xsav=-1.0;}
  }
  d1=bdata->su[i]-bdata->xopt[i]; temp=ssq-d1*d1;
  if(temp>0.0) {
  temp=sqrt(temp)+bdata->s[i];
  if(angbd*temp>tempb) {angbd=tempb/temp; iact=i+1; xsav=1.0;}
  }
  }
  if(i<bdata->n) {perp_altern=1; continue;} // Break in the loop
 
  /* Calculate HHD and some curvatures for the alternative iteration. */
  trsbox_s_multiply(bdata);
  shs=dhs=dhd=0.0;
  for(i=0; i<bdata->n; i++) if(bdata->xbdi[i]==0.0) {
  shs += bdata->s[i]*bdata->hs[i];
  dhs += bdata->dtrial[i]*bdata->hs[i];
  dhd += bdata->dtrial[i]*bdata->hred[i];
  }
 
  /* Seek the greatest reduction in Q for a range of equally spaced values
  of ANGT in [0,ANGBD], where ANGT is the tangent of half the angle of
  the alternative iteration. */
  redmax=redsav=0.0; isav=0;
  iu=(int)(angbd*17.+3.1);
  for(i=1; i<=iu; i++) {
  angt = angbd*(double)i/(double)iu;
  sth = (angt+angt)/(1.0+angt*angt);
  temp = shs+angt*(angt*dhd-dhs-dhs);
  rednew = sth*(angt*dredg-sredg-0.5*sth*temp);
  if(rednew>redmax) {redmax=rednew; isav=i; rdprev=redsav;}
  else if(i==isav+1) {rdnext=rednew;}
  redsav=rednew;
  }
 
  /* Return if the reduction is zero. Otherwise, set the sine and cosine
  of the angle of the alternative iteration, and calculate SDEC. */
  if(isav==0) {
  trsbox_set_xnew(bdata); return;
  }
  if(isav<iu) {
  temp = (rdnext-rdprev)/(redmax+redmax-rdprev-rdnext);
  angt = angbd*((double)isav+0.5*temp)/(double)iu;
  }
  d2=angt*angt; cth=(1.0-d2)/(1.0+d2);
  sth = (angt+angt)/(1.0+d2);
  temp = shs+angt*(angt*dhd-dhs-dhs);
  sdec = sth*(angt*dredg-sredg-0.5*sth*temp);
  if(sdec<=0.0) {
  trsbox_set_xnew(bdata); return;
  }
 
  /* Update GNEW, D and HRED. If the angle of the alternative iteration
  is restricted by a bound on a free variable, that variable is fixed
  at the bound. */
  dredg=gredsq=0.0;
  for(i=0; i<bdata->n; i++) {
  bdata->gnew[i]+=(cth-1.0)*bdata->hred[i]+sth*bdata->hs[i];
  if(bdata->xbdi[i]==0.0) {
  bdata->dtrial[i]=cth*bdata->dtrial[i]+sth*bdata->s[i];
  dredg+=bdata->dtrial[i]*bdata->gnew[i];
  gredsq+=bdata->gnew[i]*bdata->gnew[i];
  }
  bdata->hred[i]=cth*bdata->hred[i]+sth*bdata->hs[i];
  }
 
  qred += sdec;
  if(iact>0 && isav==iu) {
  nact++; bdata->xbdi[iact-1]=xsav;
  perp_altern=1; continue;
  }
 
  /* If SDEC is sufficiently small, then RETURN after setting XNEW to
  XOPT+D, giving careful attention to the bounds. */
  if(sdec<=0.01*qred) break;
 
  perp_altern=0;
  } // end of while
 
  trsbox_set_xnew(bdata);
  return;
 } /* bobyqa_trsbox() */
 /******************************************************************************/
 
 /******************************************************************************/
 // UPDATE
 void bobyqa_update(
  bobyqa_data *bdata
 ) {
  bdata->update_nr++;
  if(bdata->verbose>4) {printf("bobyqa_update()\n"); fflush(stdout);}
 
  int i, j, k, jp;
  double tau, temp, d1, d2;
  double alpha, tempa, tempb, ztest;
 
  /* Function Body */
  ztest = 0.0;
  for(k=0; k<bdata->npt; k++) for(j=0; j<bdata->nptm; j++) {
  d1=fabs(bdata->zmat[k + j*bdata->npt]);
  if(d1>ztest) ztest=d1;
  }
  ztest*=1.0E-20;
 
  /* Apply the rotations that put zeros in the KNEW-th row of ZMAT. */
  for(j=1; j<bdata->nptm; j++) {
  if(fabs(bdata->zmat[bdata->knew-1 + j*bdata->npt]) > ztest) {
  d1=bdata->zmat[bdata->knew-1];
  d2=bdata->zmat[bdata->knew-1 + j*bdata->npt];
  temp=hypot(d1,d2);
  tempa=bdata->zmat[bdata->knew-1] / temp;
  tempb=bdata->zmat[bdata->knew-1 + j*bdata->npt] / temp;
  for(i=0; i<bdata->npt; i++) {
  temp=tempa*bdata->zmat[i] + tempb*bdata->zmat[i + j*bdata->npt];
  if(temp<-1.0E+100) temp=-1.0E+100; // added by VO
  else if(temp>+1.0E+100) temp=+1.0E+100; // added by VO
  bdata->zmat[i + j*bdata->npt] =
  tempa*bdata->zmat[i + j*bdata->npt] - tempb*bdata->zmat[i];
  if(bdata->zmat[i + j*bdata->npt]<-1.0E+100) // added by VO
  bdata->zmat[i + j*bdata->npt]=-1.0E+100;
  else if(bdata->zmat[i + j*bdata->npt]>+1.0E+100) // added by VO
  bdata->zmat[i + j*bdata->npt]=+1.0E+100;
  bdata->zmat[i]=temp;
  }
  }
  bdata->zmat[bdata->knew-1 + j*bdata->npt]=0.0;
  }
 
  /* Put the first NPT components of the KNEW-th column of HLAG into WNDIM,
  and calculate the parameters of the updating formula. */
  for(i=0; i<bdata->npt; i++)
  bdata->wndim[i]=bdata->zmat[bdata->knew-1]*bdata->zmat[i];
  alpha=bdata->wndim[bdata->knew-1]; tau=bdata->vlag[bdata->knew-1];
  bdata->vlag[bdata->knew-1]-=1.0;
 
  /* Complete the updating of ZMAT. */
  temp=sqrt(bdata->denom);
  //if(isnan(temp) || !isfinite(temp)) temp=1.0E-20; // added by VO 2012-06-04
  if(isnan(temp) || !isfinite(temp)) temp=1.0E-50; // changed limit 2012-09-16
  tempa=tau/temp;
  //if(isnan(tempa)||!isfinite(tempa)) tempa=tau*1.0E+20; //added by VO 2012-06-04
  if(isnan(tempa)||!isfinite(tempa)) tempa=tau*1.0E+50; //changed limit 2012-09-16
  tempb=bdata->zmat[bdata->knew-1]/temp;
  if(isnan(tempa)||!isfinite(tempa))
  //tempb=bdata->zmat[bdata->knew-1]*1.0E+20; //added by VO 2012-06-04
  tempb=bdata->zmat[bdata->knew-1]*1.0E+50; //changed limit 2012-09-16
  for(i=0; i<bdata->npt; i++)
  bdata->zmat[i]=tempa*bdata->zmat[i]-tempb*bdata->vlag[i];
 
  /* Finally, update the matrix BMAT. */
  for (j = 1; j <=bdata->n; j++) {
  jp = bdata->npt + j;
  bdata->wndim[jp-1] = bdata->bmat[bdata->knew-1 + (j-1)*bdata->ndim];
  tempa=(alpha*bdata->vlag[jp-1] - tau*bdata->wndim[jp-1]) / bdata->denom;
  tempb=(-bdata->beta*bdata->wndim[jp-1]-tau*bdata->vlag[jp-1])/bdata->denom;
  for(i=1; i<=jp; i++) {
 #if(0) // original
  bdata->bmat[i-1 + (j-1)*bdata->ndim]= bdata->bmat[i-1 + (j-1)*bdata->ndim]
  + tempa*bdata->vlag[i-1] + tempb*bdata->wndim[i-1];
 #else // modified
  bdata->bmat[i-1 + (j-1)*bdata->ndim] +=
  tempa*bdata->vlag[i-1] + tempb*bdata->wndim[i-1];
 #endif
  /* Previous change should lead to same result, but some differences exist.
  Same effect is seen already in the first f2c version 110917.
  This is because of precision issues, calculations are done in different
  order, and also putting last sum in parenthesis changes the result.
  */
 
  if(i>bdata->npt) {
  bdata->bmat[jp-1 + (i-1 - bdata->npt) * bdata->ndim] =
  bdata->bmat[i-1 + (j-1)*bdata->ndim];
  }
  }
  }
 
 } /* bobyqa_update() */
 /******************************************************************************/
 
 /******************************************************************************/