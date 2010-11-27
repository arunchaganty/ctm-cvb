#
# Correlated Topic Model
# Using CVB
# Computing perplexity
#

# Let zero values stay zero
function M = safe_log( M )
    nulls = M==0;
    M = log( M );
    M(nulls) = 0;
end;

# Compute the per-word perplexity of data
function P = perplexity( C, K, phi )
    N = sum( sum( C ) );
    [D,V] = size(C);

    P = 0;
    for j = [1:K]
        P += sum( sum( C .* phi{j} .* safe_log(phi{j}) ) );
    end;
    P = exp( - P ./ N );
end;

