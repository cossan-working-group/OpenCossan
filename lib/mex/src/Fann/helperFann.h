/*
 * Mex interface for the FANN library
 * Author: Dirk Gorissen <dirk.gorissen@ua.ac.be>
 * Licence: GPL version 2 or later
 */

#ifndef HELPERFANN_INCLUDE
#define HELPERFANN_INCLUDE

#include "fann.h"
#include "fann_error.h"
#include "mex.h"

struct fann_train_data *read_from_array(const double *din,
					const double *dout,
					const unsigned int num_data,
					const unsigned int num_input,
					const unsigned int num_output);

struct fann* createNetwork(	const unsigned int numLayers,
			   	const unsigned int* layers,
                const unsigned int funType,
				const float connectionRate
			   );

struct fann* trainNetwork(struct fann *ann,
				struct fann_train_data *data,
				const float desiredError,
				const unsigned int maxEpochs
				);

void evaluateNetwork(struct fann *ann, const double *input, double* output, const unsigned int numData);

mxArray* createMatlabStruct(struct fann* ann, mxArray* layers, mxArray* funType, const float connectivity);

struct fann* createFannFromMatlabStruct(const mxArray* str);
float getConnectivity(const mxArray* str);
mxArray* getLayers(const mxArray* str);
mxArray* getFunType(const mxArray* str);

#endif
