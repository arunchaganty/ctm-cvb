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
    B = B ./ repmat( sum( B, 2 ), 1, V );

    P = 0;
    for j = [1:K];
        P += sum( sum( C .* phi{j} .* ( safe_log(phi{j}) + repmat( log( B(j,:) ), D, 1 ) ) ) );
    end;
    P = exp( - P ./ N );
end;

