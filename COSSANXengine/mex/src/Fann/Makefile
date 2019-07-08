# Makefile for building the Matlab mex interface to FANN
# Requires the fann library to be installed
# Author: Dirk Gorissen <dirk.gorissen@ua.ac.be>

MATLABDIR ?= /opt/matlab
CXX = gcc
CFLAGS = -Wall -fPIC -O3 -I$(MATLABDIR)/extern/include -I../src/include

MEX = $(MATLABDIR)/bin/mex
MEX_OPTION = CC\#$(CXX) CXX\#$(CXX) CFLAGS\#"$(CFLAGS)" CXXFLAGS\#"$(CFLAGS)" -L../src/.libs -lm -lfann
MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)

all: createFann.$(MEX_EXT) trainFann.$(MEX_EXT) testFann.$(MEX_EXT)

createFann.$(MEX_EXT):     createFann.c helperFann.h helperFann.o
	$(MEX) $(MEX_OPTION) createFann.c helperFann.o

trainFann.$(MEX_EXT):     trainFann.c helperFann.h helperFann.o
	$(MEX) $(MEX_OPTION) trainFann.c helperFann.o

testFann.$(MEX_EXT):     testFann.c helperFann.h helperFann.o
	$(MEX) $(MEX_OPTION) testFann.c helperFann.o

helperFann.o:     helperFann.c helperFann.h
	$(CXX) $(CFLAGS) -c helperFann.c

clean:
	rm -f *~ *.o; rm -f *.mex*; rm -f *obj

