/*
 * Mex interface for the FANN library
 * Author: Dirk Gorissen <dirk.gorissen@ua.ac.be>
 * Licence: GPL version 2 or later
 */
#include "helperFann.h"
#include <stdio.h>
#include "math.h"

// Note that all the code here relies on the way matlab passes arrays, this is different than in C!

//--------------------------------------------------------------------------------------------------------
/* Function code adapted from:
	http://leenissen.dk/fann/forum/viewtopic.php?p=719&sid=1661ac359e28908e704231faa6310518 
*/
struct fann_train_data *read_from_array(const double *din,
					const double *dout,
					const unsigned int num_data,
					const unsigned int num_input,
					const unsigned int num_output) {
  
  unsigned int i, j;
  fann_type *data_input, *data_output;

  struct fann_train_data *data = (struct fann_train_data *) malloc(sizeof(struct fann_train_data));
  if(data == NULL) {
    fann_error(NULL, FANN_E_CANT_ALLOCATE_MEM);
    return NULL;
  }
 
  fann_init_error_data((struct fann_error *) data);
 
  data->num_data = num_data;
  data->num_input = num_input;
  data->num_output = num_output;

  data->input = (fann_type **) calloc(num_data, sizeof(fann_type *));
  if(data->input == NULL) {
    fann_error(NULL, FANN_E_CANT_ALLOCATE_MEM);
    fann_destroy_train(data);
    return NULL;
  }
 
  data->output = (fann_type **) calloc(num_data, sizeof(fann_type *));
  if(data->output == NULL) {
    fann_error(NULL, FANN_E_CANT_ALLOCATE_MEM);
    fann_destroy_train(data);
    return NULL;
  }
 
  data_input = (fann_type *) calloc(num_input * num_data, sizeof(fann_type));
  if(data_input == NULL) {
    fann_error(NULL, FANN_E_CANT_ALLOCATE_MEM);
    fann_destroy_train(data);
    return NULL;
  }
 
  data_output = (fann_type *) calloc(num_output * num_data, sizeof(fann_type));
  if(data_output == NULL) {
    fann_error(NULL, FANN_E_CANT_ALLOCATE_MEM);
    fann_destroy_train(data);
    return NULL;
  }
 
  //Code changed to support the way matlab passes arrays
  for(i = 0; i != num_data; i++) {
    data->input[i] = data_input;
    data_input += num_input;
   
    for(j = 0; j != num_input; j++) {
      data->input[i][j] = din[(j*num_data)+i];
	//printf("input (%i,%i) = %f\n",i,j,data->input[i][j]);
    }
   
   
    data->output[i] = data_output;
    data_output += num_output;
   
    for(j = 0; j != num_output; j++) {
      data->output[i][j] = dout[(j*num_data)+i];
	//printf("output (%i,%i) = %f\n",i,j,data->output[i][j]);
    }
  }
  return data;
}
//--------------------------------------------------------------------------------------------------------
struct fann* createNetwork(	const unsigned int numLayers,
			   	const unsigned int* layers,
			   	const unsigned int funType,
				const float connectionRate
			   ){

	struct fann *ann = fann_create_sparse_array(connectionRate, numLayers, layers);
	
	fann_randomize_weights(ann, -1, 1);
    switch (funType){
    case 1:
        fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC);
        break;
    case 2:
        fann_set_activation_function_hidden(ann, FANN_GAUSSIAN_SYMMETRIC);
        break;
    case 3:
        fann_set_activation_function_hidden(ann, FANN_LINEAR_PIECE_SYMMETRIC);
        break;
    default:
        fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC);
    }
	fann_set_activation_function_output(ann, FANN_LINEAR);

	fann_set_training_algorithm(ann, FANN_TRAIN_RPROP);
	fann_set_train_error_function(ann, FANN_ERRORFUNC_LINEAR);
	//fann_set_train_error_function(ann, FANN_ERRORFUNC_TANH);
	fann_set_train_stop_function(ann, FANN_STOPFUNC_MSE);

	return ann;
}
//--------------------------------------------------------------------------------------------------------
struct fann* trainNetwork(struct fann *ann,
				struct fann_train_data *data,
				const float desiredError,
				const unsigned int maxEpochs
				){

	const unsigned int epochsBetweenReports = 0;

	//train the network
	fann_train_on_data(ann, data, maxEpochs, epochsBetweenReports, desiredError);
	return ann;
}
//--------------------------------------------------------------------------------------------------------
//Evaluate the ann on an array of samples
void evaluateNetwork(struct fann *ann, const double *input, double* output, const unsigned int numData){
	
	int i,j;
	unsigned int numInputs = fann_get_num_input(ann);
	unsigned int numOutputs = fann_get_num_output(ann);
	fann_type *out;
	
  	fann_type *in = (fann_type *)malloc(numInputs * sizeof(fann_type));
	if(in == NULL) {
    		fann_error(NULL, FANN_E_CANT_ALLOCATE_MEM);
  	}


	for(i=0;i<numData;++i){
		//printf("adding to input: ");
		for(j=0;j<numInputs;j++) {
			in[j] = input[(j*numData)+i];
			//printf("%f  ",in[j]);
		}
		//printf("\n");

		out = fann_run(ann,in);

		//printf("adding to output: ");
		for(j=0;j<numOutputs;j++) {
			output[(j*numData)+i] = out[j];
			//printf("%f  ",out[j]);
		}
		//printf("\n");
	}

	free(in);
}
//--------------------------------------------------------------------------------------------------------
mxArray* createMatlabStruct(struct fann* ann, mxArray* layers, mxArray* funType, const float connectivity){
	//The struct field names
	const char *fnames[] = {"layers","function_type","weights","from","to", "connectivity"};

	//the struct itself
	mxArray* str = mxCreateStructMatrix(1, 1, 6, fnames);
	
	//Get the connection information	
	unsigned int numConnections = fann_get_total_connections(ann);

	struct fann_connection *connections = malloc(sizeof(struct fann_connection) * numConnections);

	mxArray* weights = mxCreateDoubleMatrix(numConnections, 1, mxREAL);
	mxArray* from = mxCreateDoubleMatrix(numConnections, 1, mxREAL);
	mxArray* to = mxCreateDoubleMatrix(numConnections, 1, mxREAL);
	mxArray* conn = mxCreateDoubleMatrix(1, 1, mxREAL);

	double* w = mxGetPr(weights);	
	double* f = mxGetPr(from);	
	double* t = mxGetPr(to);	
	double* c = mxGetPr(conn);	
    
	unsigned int index;
    
	if(connections == NULL) {
    		fann_error(NULL, FANN_E_CANT_ALLOCATE_MEM);
  	}

	fann_get_connection_array(ann, connections);

	c[0] = connectivity;

	for (index = 0; index < numConnections; index++) {
        	w[index] = connections[index].weight;
        	f[index] = connections[index].from_neuron;
        	t[index] = connections[index].to_neuron;
		//printf("Adding triple %f\t%f\t%f\n",w[index],f[index],t[index]);
 	}

	//Free the connections memory
	free(connections);

	//Set all the fields on the matlab struct
	mxSetFieldByNumber(str, 0, 0, layers);
	mxSetFieldByNumber(str, 0, 1, funType);
	mxSetFieldByNumber(str, 0, 2, weights);
	mxSetFieldByNumber(str, 0, 3, from);
	mxSetFieldByNumber(str, 0, 4, to);
	mxSetFieldByNumber(str, 0, 5, conn);

	return str;
}
//--------------------------------------------------------------------------------------------------------
float getConnectivity(const mxArray* str){
	mxArray* conn = mxGetFieldByNumber(str,0, 4);
	return (float)mxGetScalar(conn);
}
//--------------------------------------------------------------------------------------------------------
mxArray* getLayers(const mxArray* str){
	return mxGetFieldByNumber(str,0, 0);
}
//--------------------------------------------------------------------------------------------------------
mxArray* getFunType(const mxArray* str){
	return mxGetFieldByNumber(str,0, 1);
}
//--------------------------------------------------------------------------------------------------------
struct fann* createFannFromMatlabStruct(const mxArray* str){

	//read all the fields from the matlab structure
	mxArray* layers 	= mxGetFieldByNumber(str,0, 0);
	mxArray* funType 	= mxGetFieldByNumber(str,0, 1);
	mxArray* weights 	= mxGetFieldByNumber(str,0, 2);
	mxArray* from 		= mxGetFieldByNumber(str,0, 3);
	mxArray* to 		= mxGetFieldByNumber(str,0, 4);
	mxArray* conn 		= mxGetFieldByNumber(str,0, 5);
	
	unsigned int numLayers = mxGetN(layers);
	double* tmpLayers = mxGetPr(layers);
	unsigned int fun = mxGetN(funType);
	double* w = mxGetPr(weights);	
	double* f = mxGetPr(from);	
	double* t = mxGetPr(to);	
	float c = (float)mxGetScalar(conn);	
	struct fann *ann;
	unsigned int numConnections;
	struct fann_connection *connections;
	unsigned int index;
	
	//get the layers
	int j=0;
	unsigned int *l = malloc(numLayers * sizeof(unsigned int));
	if(l == NULL) {
    		fann_error(NULL, FANN_E_CANT_ALLOCATE_MEM);
  	}

	for(j=0;j<numLayers;j++) {
		l[j] = (unsigned int) tmpLayers[j];
	}
	
	//Create the network
	ann = createNetwork(numLayers,l,fun,c);

	//can I free the l array here?

	//Create an array of connection structures
	numConnections = mxGetM(weights);

	connections = malloc(sizeof(struct fann_connection) * numConnections);
	if(connections == NULL) {
    		fann_error(NULL, FANN_E_CANT_ALLOCATE_MEM);
  	}

	//fill it up
	for (index = 0; index < numConnections; index++) {
        	connections[index].weight = w[index];
        	connections[index].from_neuron = f[index];
        	connections[index].to_neuron = t[index];
		//printf("Setting triple %f\t%f\t%f\n",w[index],f[index],t[index]);
 	}

	//Now set the connections on the network
	fann_set_weight_array(ann, connections, numConnections);

	//release memory for the connections array
	free(connections);	

	return ann;
}
//--------------------------------------------------------------------------------------------------------
int main(){
	return 0;
}
//--------------------------------------------------------------------------------------------------------
