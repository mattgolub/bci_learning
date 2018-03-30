function y = percentile(x,Ps)
% x is a row or column vector (no matrix support yet)
% Ps is a vector of [0 100]
%
% @ Matt Golub, 2018.

% From wikipedia: http://en.wikipedia.org/wiki/Percentile
%
% Linear interpolation between closest ranks
% An alternative to rounding used in many applications is to use linear
% interpolation between the two nearest ranks. In particular, given the N
% sorted values, v(1),...,v(N), we define the percent rank corresponding to
% the nth value as: p(n) = (100/N)*(n - 1/2).
%
% In this way, for example, if N = 5, the percent rank corresponding to the
% third value is p(3) = (100/5)*(3-1/2) = 50.
%
% The value v of the P-th percentile may now be calculated as follows:
% If P<p(1) or P>p(N), then we take v = v(1) or v = v(N), respectively.
%
% If there is some integer k for which P=p(k), then we take v = v(k).
% Otherwise, we find the integer k for which p(k)<P<p(k+1), and take
% v = v(k) + (P-p(k))/(p(k+1) - p(k)) * (v(k+1) - v(k))
%   = v(k) + N * (P-p(k))/100 * (v(k+1) - v(k)).Specifically:
%
% It is readily confirmed that the 50th percentile of any list of values
% according to this definition of the P-th percentile is just the sample
% median. Moreover, when N is even the 25th percentile according to this
% definition of the P-th percentile is the median of the first  values
% (i.e., the median of the lower half of the data).

x = x(~isnan(x));
y = nan(size(Ps));

N = length(x);

if N==0
    return
end

v = sort(x,'ascend');

p = (100/N) * ((1:N) - 0.5);

for i = 1:numel(Ps)
    P = Ps(i);
    if P<p(1)
        y(i) = v(1);
    elseif P>p(N)
        y(i) = v(N);
    else
        p_eq_P = p==P;
        if any(p_eq_P)
            y(i) = v(p_eq_P);
        else
            k = find(P>p,1,'last');
            y(i) = v(k) + (P-p(k))/(p(k+1)-p(k)) * (v(k+1) - v(k));
        end
    end
end