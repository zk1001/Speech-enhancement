function x = safeGather(x)
% safeGather   Gather array if gather is defined

% Copyright 2015 The MathWorks, Inc.

try
    x = gather(x);
catch exception
    if iUndefinedFunction( exception )
        % Assume gather not defined for this type
    else
        rethrow( exception );
    end
end

end

function tf = iUndefinedFunction( exception )
tf = isequal( exception.identifier, 'MATLAB:UndefinedFunction' );
end
