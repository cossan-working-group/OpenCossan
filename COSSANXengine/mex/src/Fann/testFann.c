/*
 * Mex interface for the FANN library
 * Author: Dirk Gorissen <dirk.gorissen@ua.ac.be>
 * Licence: GPL version 2 or later
 */

#include "helperFann.h"
#include <stdio.h>

//--------------------------------------------------------------------------------------------------------
//Calling syntax: [values] = testFann(ann,samples);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    // variable declaration
	struct fann* ann;
	unsigned int numInputs;
	unsigned int numOutputs;
	const mxArray *xData;
	const double* samples;
	int sRowLen;
	int sColLen;
	double *values;
    
    
	if(nrhs != 2){
		mexErrMsgTxt("testFann usage: 'values = testFann(ann,samples)'");
		return;
	}

	ann = createFannFromMatlabStruct(prhs[0]);

	numInputs = fann_get_num_input(ann);
	numOutputs = fann_get_num_output(ann);

	//Get the samples
	xData = prhs[1];
	samples = mxGetPr(xData);
	sRowLen = mxGetN(xData);
	sColLen = mxGetM(xData);
	//printf("%i by %i samples received\n",sRowLen,sColLen);

	if(numInputs != sRowLen){
		mexErrMsgTxt("The network input dimension does not match the dimension of the passed samples!");
		return;
	}

	//Allocate memory and assign output pointer
	plhs[0] = mxCreateDoubleMatrix(sColLen, numOutputs, mxREAL);

	//Get a pointer to the data space in our newly allocated memory
	values = mxGetPr(plhs[0]);

	//evaluate the network on the given samples
	evaluateNetwork(ann, samples, values, sColLen);

	//printf("The tested network is\n");
	//fann_print_connections(ann);

	//destroy the ann since its no longer needed
	fann_destroy(ann);
}
//--------------------------------------------------------------------------------------------------------
