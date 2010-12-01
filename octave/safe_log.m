# Let zero values don't go to inf.
function M = safe_log( M )
    nulls = M==0;
    M = log( M );
    M(nulls) = -1e3;
    M(M < -1e3) = -1e3;
end;
