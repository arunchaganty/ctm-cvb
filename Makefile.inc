# vim: ft=make

# put common definitions in here
CC		 = g++
DEBUG    = -O0 -g
CFLAGS	 = $(DEBUG) -Wall -I$(ROOTDIR)include/ 
CXXFLAGS = $(CFLAGS)
LDFLAGS	 = -g

