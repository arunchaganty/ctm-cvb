#
# Correlated Topic Model
# Using CVB
# Computing perplexity
#

# Compute the per-word perplexity of data
function P = perplexity( C, B, K, phi )
    N = sum( sum( C ) );
    [D,V] = size(C);

    # Convert to p-dist
    logB = safe_log(B);
    logB = B - repmat( logsum( B, 2 ), 1, V );

    P = 0;
    perp = zeros( D*V, K );
    for j = [1:K];
        perp(:, j) = (safe_log(phi{j}) + repmat( logB(j,:), D, 1 ) )(:);
    end;
    P = sum( logsum( perp ) );
    P = exp( - P ./ N );
end;

