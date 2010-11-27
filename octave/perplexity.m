#
# Correlated Topic Model
# Using CVB
# Computing perplexity
#

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

