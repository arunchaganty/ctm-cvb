#
#
#

def parse_tc( term_count_str ):
    return map( int, term_count_str.split( ':' ) )

def scan( f ):
    V = 0
    for line in f.readlines():
        term_counts = line.split()[1:]
        max_ = max( [ parse_tc( tc )[0] for tc in term_counts ] )
        V = max( V, max_ )

    f.seek( 0 )

    return V

def convert( f, V ):
    for line in f.readlines():
        term_counts = line.split()[1:]
        term_counts = map( parse_tc, term_counts )
        # Print 0's until you reach the next idx

        i = 0

        csv = []
        for j in xrange( V ):
            if i < len( term_counts) and j == term_counts[ i ][ 0 ]:
                csv.append( str( term_counts[ i ][ 1 ] ) )
                i += 1
            else:
                csv.append( str( 0 ) )

        print ", ".join( csv )

def main( args ):
    fname = args[ 0 ] 
    f = open( fname, "r" )

    V = scan( f )
    convert( f, V )

if __name__ == "__main__":
    import sys
    main( sys.argv[1:] )


