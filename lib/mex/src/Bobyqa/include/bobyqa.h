 /******************************************************************************
  Copyright (c) 2012 by Turku PET Centre
 
  File: bobyqa.h
  Description: See bobyqa.c.
 
  Modification history:
  2012-09-05 Vesa Oikonen
  First created.
  2012-09-07 VO
  Added bobyqa_result enums BOBYQA_FAIL, BOBYQA_RELFTOL_REACHED, and
  BOBYQA_ABSFTOL_REACHED.
 
 
 
 ******************************************************************************/
 #ifndef _BOBYQA_H
 #define _BOBYQA_H
 #ifndef M_SQRT2
 #define M_SQRT2 1.41421356237309504880
 #endif
 /*****************************************************************************/
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include <math.h>
 #include <float.h>
 /*****************************************************************************/
 typedef enum {
  BOBYQA_INVALID_ARGS = -1,
  BOBYQA_OUT_OF_MEMORY = -2,
  BOBYQA_ROUNDOFF_LIMITED = -3,
  BOBYQA_FAIL = -4, /* generic fail code */
  BOBYQA_SUCCESS = 0, /* generic success code */
  BOBYQA_MINF_MAX_REACHED = 1,
  BOBYQA_FTOL_REACHED = 2,
  BOBYQA_XTOL_REACHED = 3,
  BOBYQA_MAXEVAL_REACHED = 4,
  BOBYQA_RELFTOL_REACHED = 5,
  BOBYQA_ABSFTOL_REACHED = 6
 } bobyqa_result;
 /*****************************************************************************/
 typedef double (*bobyqa_func)(int n, const double *x, void *func_data);
 /*****************************************************************************/
 typedef struct { // bobyca data in a struct by VO
  int n;
  int npt;
  double *x;
  int x_size;
  double *xscale;
  int xscale_size;
  int nfull;
  double *xfull;
  int *xplace;
  double *xl;
  int xl_size;
  double *xu;
  int xu_size;
  double rhobeg;
  double rhoend;
  double minf_max;
  double ftol_rel;
  double ftol_abs;
  int maxeval;
  int nevals;
 
  bobyqa_func objf;
  void *objf_data;
  double minf;
 
  double *wmptr;
  double *lwmptr;
  int *liwmptr;
 
  double *xbase;
  int xbase_size;
  double *xpt;
  int xpt_size;
  double *fval;
  int fval_size;
  double *xopt;
  int xopt_size;
  /* GOPT holds the gradient of the quadratic model at XBASE+XOPT. */
  double *gopt;
  int gopt_size;
  double *hq;
  int hq_size;
  double *pq;
  int pq_size;
  double *bmat;
  int bmat_size;
  double *zmat;
  int zmat_size;
  int ndim;
  double *sl;
  int sl_size;
  double *su;
  int su_size;
  double *xnew;
  int xnew_size;
  double *xalt;
  int xalt_size;
  double *dtrial;
  int dtrial_size;
  double *vlag;
  int vlag_size;
 
  double *w2npt;
  int w2npt_size;
  double *wndim;
  int wndim_size;
  double *wn;
  int wn_size;
  double *gnew;
  int gnew_size;
  double *xbdi;
  int xbdi_size;
  double *s;
  int s_size;
  double *hs;
  int hs_size;
  double *hred;
  int hred_size;
  double *glag;
  int glag_size;
  double *hcol;
  int hcol_size;
  double *ccstep;
  int ccstep_size;
 
  int verbose;
 
  double _crvmin;
  int ntrits;
  double rho;
  int nresc;
  double delta;
  double diffa, diffb, diffc;
  double ratio;
  int itest;
  int nfsav;
  int kopt;
  double fsave;
  double vquad;
  double fopt;
  double dsq, xoptsq;
  int nptm;
  double alpha, beta;
  double dnorm;
  int rc; // return code
  double newf;
  int knew, kbase;
  double denom, delsq, scaden, biglsq, distsq;
  double cauchy, adelt;
  // Nr of subfunction calls
  int prelim_nr, rescue_nr, altmov_nr, trsbox_nr, update_nr;
 } bobyqa_data;
 /*****************************************************************************/
 extern bobyqa_result bobyqb(bobyqa_data *bdata);
 extern bobyqa_result bobyqa(
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
 );
 extern int bobyqa_minimize_single_parameter(bobyqa_data *bdata);
 extern char *bobyqa_rc(bobyqa_result rc);
 extern int fixed_params(
  int n, const double *lower, const double *upper, const double *delta
 );
 extern int bobyqa_working_memory_size(
  int n, int fitted_n, int npt, bobyqa_data *bdata
 );
 extern bobyqa_result bobyqa_set_memory(
  int n, int fitted_n, int npt, bobyqa_data *bdata, double *wm
 );
 extern bobyqa_result bobyqa_free_memory(bobyqa_data *bdata);
 extern bobyqa_result bobyqa_reset_memory(bobyqa_data *bdata);
 extern void bobyqa_print(bobyqa_data *bdata, int sw, FILE *fp);
 extern double bobyqa_x_funcval(bobyqa_data *bdata, double *x);
 extern void bobyqa_xfull(bobyqa_data *bdata);
 
 extern bobyqa_result bobyqa_set_optimization(
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
 );
 /*****************************************************************************/
#endif /* _BOBYQA_H */