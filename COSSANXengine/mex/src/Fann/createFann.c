/*
 * Mex interface for the FANN library
 * Author: Dirk Gorissen <dirk.gorissen@ua.ac.be>
 * Licence: GPL version 2 or later
 */

#include "helperFann.h"
#include <stdio.h>

//--------------------------------------------------------------------------------------------------------
//Calling syntax: [ann] = createFann(layers,connectivity);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
	
	//Declarations
	const mxArray *xData;
	double *xValues, *xType;
	int j;
	int numLayers, lRowDataLen, lColDataLen;
    unsigned int *layers;
    unsigned int fun_type;
	float connectivity;
	struct fann *ann;
	mxArray *layersCopy; 
    mxArray *funTypeCopy;

	if(nrhs == 3){
		//do nothing
	}else{
		mexErrMsgTxt("createFann usage: 'ann = createFann(layers,activation_functions_type,connectivity)'");
		return;

	}

	//Get the layers
	xData = prhs[0];
	xValues = mxGetPr(xData);
	lRowDataLen = mxGetN(xData);
	lColDataLen = mxGetM(xData);
    
    //Get the activation function type
    xData = prhs[1];
	xType = mxGetPr(xData);

	if(lColDataLen != 1){
		mexErrMsgTxt("Layers must be a vector!");
		return;
	}    
    
	numLayers = lRowDataLen;

	layers = mxCalloc(numLayers, sizeof(unsigned int));
    fun_type  = (unsigned int) xType;

	for(j=0;j<numLayers;j++) {
		layers[j] = (unsigned int) xValues[j];
	}	

	//Get the connectivity
	connectivity = (float)(mxGetScalar(prhs[2]));

	//Create the network
	ann = createNetwork(numLayers,layers,fun_type,connectivity);
    
    //save the node numbers
	layersCopy = mxDuplicateArray(prhs[0]);
    //save the activation function type
    funTypeCopy = mxDuplicateArray(prhs[1]);

	//Create the struct representing this ann in matlab
	plhs[0] = createMatlabStruct(ann, layersCopy, funTypeCopy, connectivity);

	//printf("The created network is\n");
	//fann_print_connections(ann);

	//destroy the ann its no longer needed
	fann_destroy(ann);
}
//--------------------------------------------------------------------------------------------------------
