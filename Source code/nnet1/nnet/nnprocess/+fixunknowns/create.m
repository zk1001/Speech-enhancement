function [y,settings] = create(x,param)
%PROCESSPCA.FIXUNKNOWNS Create settings for processing values

% Copyright 2012-2015 The MathWorks, Inc.

% Get info from X which may be MATLAB array or gpuArray
unknown_rows = iGather(any( isnan( x ), 2 ).');
settings.xrows = size(x,1);
settings.yrows = settings.xrows + sum(unknown_rows);
settings.unknown = find(unknown_rows);
settings.known = find(~unknown_rows);
settings.shift = [0 cumsum(unknown_rows(1:(end-1)))];
settings.xmeans = iFiniteMeans( x );
settings.xknown = settings.known;
settings.xunknown = settings.unknown;
settings.yknown = settings.known + settings.shift(settings.known);
settings.yunknown = settings.unknown + settings.shift(settings.unknown);
settings.yflags = settings.yunknown+1;

% Check whether processing has any effect
settings.no_change = isempty(settings.unknown);

% Apply
y = fixunknowns.apply(x,settings);
end

function xmeans = iFiniteMeans( x )
numRows = size( x, 1 );
xmeans = zeros( numRows, 1 );
for i = 1:numRows
    xmeans(i) = iFiniteMeanForRow( x(i,:) );
end
end

function xmean = iFiniteMeanForRow( row )
xi = iGather(row);
xi = xi(isfinite(xi));
if isempty(xi)
    xmean = 0;
else
    xmean = mean(xi);
end
end

function x = iGather( x )
if isobject( x )
    try %#ok<TRYNC>
        x = gather( x );
    end
end

end
