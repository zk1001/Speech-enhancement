function [y,settings] = create(x,param)
%PROCESSPCA.CREATE Create settings for processing values

% Copyright 2012-2015 The MathWorks, Inc.

% Remove samples with NaN elements
[~,j] = find(isnan(x));
x(:,unique(j)) = [];

% Get info from X which may be MATLAB array or gpuArray
[R,Q]=size(x);
settings.name = 'processpca';
settings.xrows = R;
settings.maxfrac = param.maxfrac;

% Cases which will not be transformed
if (R == 0) || (R == 1) || (Q == 0) || (R > Q) || any(any(isinf(x)))
    settings.yrows = R;
    settings.transform = eye(R);
    settings.inverseTransform = eye(R);
    settings.no_change = true;
    
else
    % Use the singular value decomposition to compute the principal components
    [transform,s] = iSvd(x);
    % Compute the variance of each principal component
    var = diag(s).^2/(Q-1);
    % Compute total variance and fractional variance
    total_variance = sum(var,1);
    frac_var = var./total_variance;
    % Find the components which contribute more than min_frac of the total variance
    yrows = sum(frac_var >= param.maxfrac);
    % Reduce the transformation matrix appropriately
    settings.yrows = yrows;
    settings.transform = transform(:,1:yrows)';
    settings.inverseTransform = pinv(settings.transform);
    
    % Check whether processing has any effect
    settings.no_change = (settings.xrows == settings.yrows) && ...
        all(all(transform == eye(settings.xrows)));
end

% Apply
y = processpca.apply(x,settings);
end

function [transform,s] = iSvd(x)
if(issparse(x))
    % Sparse data
    [transform,s] = svds(x,size(x,2));
    transform = full(transform);
    s = full(s);
else
    % Regular or gpuArray data
    % SVD returns inconsistent signs for regular/gpuArray data,
    % so only regular data SVD is used.
    [transform,s] = svd(nnet.array.safeGather(x),0);
end
end
