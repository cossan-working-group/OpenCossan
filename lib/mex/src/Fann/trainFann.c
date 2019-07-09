/*
 * Mex interface for the FANN library
 * Author: Dirk Gorissen <dirk.gorissen@ua.ac.be>
 * Licence: GPL version 2 or later
 */

#include "helperFann.h"
#include <stdio.h>

//--------------------------------------------------------------------------------------------------------
//Calling syntax: [ann] = trainFann(ann,samples,values,[desired error],[max epochs]);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
	
	//Declarations
	const mxArray *xData;
	int sRowLen, sColLen, vRowLen, vColLen;

	float desiredError = 1e-5;
	unsigned int maxEpochs = 5000;
       
	double* samples;
	double* values;
	struct fann* ann;
	float connectivity ;
	unsigned int numInputs;
	unsigned int numOutputs;
    struct fann_train_data *data;
	mxArray *layersCopy;
    mxArray *funTypeCopy;
    
	
	if(nrhs == 3){
		//do nothing
	}else if(nrhs == 4){
		//desired error passed
		xData = prhs[3];
		desiredError = (float) mxGetScalar(xData);
	}else if(nrhs == 5){
		//epochs passed
		xData = prhs[4];
		maxEpochs = (unsigned int) mxGetScalar(xData);
	}else{
		mexErrMsgTxt("trainFann usage: 'ann = trainFann(ann, samples, values, [desired error], [max epochs]''");
		return;

	}

	//Get the samples
	xData = prhs[1];
	samples = mxGetPr(xData);
	sRowLen = mxGetN(xData);
	sColLen = mxGetM(xData);
	//printf("%i by %i samples received\n",sRowLen,sColLen);

	//Get the values
	xData = prhs[2];
	values = mxGetPr(xData);
	vRowLen = mxGetN(xData);
	vColLen = mxGetM(xData);
	//printf("%i by %i values received\n",vRowLen,vColLen);

	if(sColLen != vColLen){
		mexErrMsgTxt("The number of samples and values must be equal");
		return;
	}

	//Create the network
	ann = createFannFromMatlabStruct(prhs[0]);
	
	connectivity = getConnectivity(prhs[0]);
	numInputs = fann_get_num_input(ann);
	numOutputs = fann_get_num_output(ann);
	
	//if training data was passed
	if(sColLen > 0){
		if(numInputs != sRowLen){
			mexErrMsgTxt("The dimension of the passed samples does not match the input dimension of the network");
			return;
		}
	
		if(numOutputs != vRowLen){
			mexErrMsgTxt("The dimension of the passed values does not match the output dimension of the network");
			return;
		}

		//Create the training data structure
		data = read_from_array(samples,values,sColLen,numInputs,numOutputs);
	
		//int num = fann_length_train_data(data);
		//int numIn = fann_num_input_train_data(data);
		//int numOut = fann_num_output_train_data(data);
		//printf("\nDataset: %i patterns, %i inputs, %i outputs\n",num,numIn,numOut);
	
		//train the network
		ann = trainNetwork(ann,data,desiredError,maxEpochs);
	
		//destroy the training structure, its no longer needed
		fann_destroy_train(data);
	}

	layersCopy = mxDuplicateArray(getLayers(prhs[0]));
    funTypeCopy = mxDuplicateArray(getFunType(prhs[0]));

	//Create the struct representing this ann in matlab
	plhs[0] = createMatlabStruct(ann, layersCopy, funTypeCopy, connectivity);

	//printf("The trained network is\n");
	//fann_print_connections(ann);

	//destroy the ann its no longer needed
	fann_destroy(ann);
}
//--------------------------------------------------------------------------------------------------------
