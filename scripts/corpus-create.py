#!/usr/bin/env python
# Create a processed corpus from a collection of text files
# Invocation: corpus-create <list-of-files>
# Output: 2 files, corpus.dat vocab.txt
# Data format:
# [M] [term_1]:[count_1] [term_2]:[count_2] ...  [term_N]:[count_3]

import sys
import nltk                 # Required for lemmatisation

TERM_FILE = "corpus.dat"
VOCAB_FILE = "vocab.txt"

LANG = "english"
THRESHOLD = 5 

options = {
    "stopwords" : False,     # Process stopwords
    "lemmatise" : False,     
    "threshold" : False,     
}
alpha = "abcdefghijklmnopqrstuvwxyz"
bridge = "'- "

def construct_dictionary( files ):
    global options
    global alpha
    global bridge

    lemmatiser = nltk.WordNetLemmatizer()
    stops = nltk.corpus.stopwords.words( LANG )

    dictionary = {}

    # Run through every file, tokenising by words
    for fname in files:
        with open(fname, "r") as f:
            for line in f:
                words = filter( lambda c: c in alpha + bridge, line.lower() ).split()
                for w in words:
                    # Hack for single-letter words like ' or -
                    if len(w) == 1 and w[0] in bridge: continue 
                    if options[ "stopwords" ] and w in stops: continue
                    if options[ "lemmatise" ]: w = lemmatiser.lemmatize( w )
                    # increment dictionary counts
                    if w in dictionary:
                        dictionary[w] += 1
                    else:
                        dictionary[w] = 1
                
    dictionary = dictionary.items()
    if options[ "threshold" ]:
        dictionary = filter( lambda x: x[1] > THRESHOLD, dictionary )

    # Sort and index
    dictionary.sort()
    for i in xrange( len( dictionary ) ):
        dictionary[i] = (dictionary[i][0], i)

    return dict( dictionary )

def find_counts( files, dictionary ):
    global options 
    global alpha 
    global bridge

    lemmatiser = nltk.WordNetLemmatizer()
    stops = nltk.corpus.stopwords.words( LANG )

    # Run through every file, tokenising by words
    terms = {}
    for fname in files:
        terms[ fname ] = {}

        with open(fname, "r") as f:
            for line in f:
                words = filter( lambda c: c in alpha + bridge, line.lower() ).split()

                for w in words:
                    # Hack for single-letter words like ' or -
                    if len(w) == 1 and w[0] in bridge: continue 
                    if options[ "stopwords" ] and w in stops: continue
                    if options[ "lemmatise" ]: w = lemmatiser.lemmatize( w )

                    try:
                        idx = dictionary[ w ]

                        # increment term counts
                        if idx in terms[ fname ]:
                            terms[ fname ][ idx ] += 1
                        else:
                            terms[ fname ][ idx ] = 1
                    except KeyError:
                        pass
    return terms

def write_vocab( dictionary, out ):
    # Open out file
    with open( out, "w" ) as f:
        dictionary = dictionary.items()
        dictionary.sort( key = lambda x: x[ 1 ] )
        for d in dictionary:
            f.write( "%s\n"%( d[ 0 ] ) )

def write_terms( terms, out ):
    # Open out file
    with open( out, "w" ) as f:
        terms = terms.items()
        terms.sort()
        for fname, terms_ in terms:
            terms_ = terms_.items()
            terms_.sort()

            d_str = ""
            d_str += "%d "%( len( terms_ ) )
            for t in terms_:
                d_str += "%d:%d "%( t[ 0 ], t[ 1 ] )

            f.write( d_str[:-1] + "\n" )

def main( files ):
    """@params list of files to be processed"""

    print( "Constructing Dictionary..." )
    dictionary = construct_dictionary( files )
    print( "Counting terms..." )
    terms = find_counts( files, dictionary )

    print( "Saving..." )
    write_vocab( dictionary, VOCAB_FILE )
    write_terms( terms, TERM_FILE )
    print( "Done." )

def print_help( argv ):
    print( "%s [-slt] <list-of-files>"%( argv[ 0 ] ) )
    print( "%s -h"%( argv[ 0 ] ) )
    print( "-s : Remove stop words" )
    print( "-l : Lemmatise" )
    print( "-t : Threshold" )

if __name__ == "__main__":
    if len( sys.argv ) == 1 or ( len( sys.argv ) == 2 and sys.argv[ 1 ] == "-h" ):
        print_help( sys.argv )
    elif len( sys.argv ) > 2 and sys.argv[ 1 ][0] == "-":
        if 's' in sys.argv[ 1 ]:
            options[ "stopwords" ] = True
        if 'l' in sys.argv[ 1 ]:
            options[ "lemmatise" ] = True
        if 't' in sys.argv[ 1 ]:
            options[ "threshold" ] = True
        main( sys.argv[ 2: ] )
    elif len( sys.argv ) > 1 and sys.argv[ 1 ][0] != "-":
        main( sys.argv[ 1: ] )
    else:
        print_help( sys.argv )

