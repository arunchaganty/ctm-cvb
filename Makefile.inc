# vim: ft=make

# put common definitions in here
CC		 = g++
DEBUG    = -O0 -g
CFLAGS	 = $(DEBUG) -Wall -I$(ROOTDIR)include/ `pkg-config --cflags gsl`
CXXFLAGS = $(CFLAGS)
LDFLAGS	 = -g `pkg-config --libs gsl`

