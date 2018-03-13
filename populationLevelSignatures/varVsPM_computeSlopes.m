function slopes = varVsPM_computeSlopes(Ydata,Xdata)
% Individual experiment regressions
%
% Ydata and Xdata are matrices with data points from individual experiments
% as rows.

nExps = size(Ydata,1);
slopes = nan(nExps,1);
for expIdx = 1:nExps
    % Solve for Y = X*B, i.e., regress(Y,X)
    nFactors = sum(~isnan(Ydata(expIdx,:)));
    
    Y = Ydata(expIdx,1:nFactors)';
    X = [Xdata(expIdx,1:nFactors)' ones(nFactors,1)];
    
    B = inv(X'*X)*X'*Y;
    % B = regress(Y,X); % equivalent
    slopes(expIdx) = B(1);
    
    % For when you inevitable need to plot one example experiment.
    % plot(X(:,1),Y,'ro'); % data
    % hold on;
    % plot(X(:,1),X*B,'go')% linear fit
end 

end