#!/usr/bin/env python
# Split a corpus for cross-validation
# Invocation: cv-split <corpus> <K-fold>
# Output: 2*K files, train-K.dat test-K.dat
# Data format:
# [M] [term_1]:[count_1] [term_2]:[count_2] ...  [term_N]:[count_3]

import sys

def main( args ):
    corpus = args[ 0 ]
    K = int( args[ 1 ] )
    if len(args) == 3:
        train_tmpl = args[2] + "-train-%d.dat"
        test_tmpl = args[2] + "-test-%d.dat"
    else:
        train_tmpl = "train-%d.dat"
        test_tmpl = "test-%d.dat"

    if corpus == "-":
        docs = sys.stdin.readlines() 
    else:
        docs = open( corpus, "r" ).readlines() 
    fold_size = len(docs) / K

    print "Generating %d sets of %d documents. Fold size is %d"%( K, len(docs), fold_size )

    for i in xrange( K ):
        with open( train_tmpl%( i ), "w" ) as train:
            train.writelines( docs[ : (i * fold_size) ] )
            train.writelines( docs[ (i+1) * fold_size : K * fold_size ] )
        with open( test_tmpl%( i ), "w" ) as test:
            test.writelines( docs[ i * fold_size : (i+1) * fold_size ] )

def print_help( argv ):
    print( "%s <corpus> <K-fold> [prefix]"%( argv[ 0 ] ) )
    print( "%s -h"%( argv[ 0 ] ) )

if __name__ == "__main__":
    if len( sys.argv ) == 1 or ( "-h" in sys.argv ):
        print_help( sys.argv )
    elif len( sys.argv ) == 3 or len( sys.argv ) == 4:
        main( sys.argv[ 1: ] )
    else:
        print_help( sys.argv )

