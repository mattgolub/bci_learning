function [progress, angles] = computeProgressOfProjection(v,cursorToTarget)
% v is dxN
% cursorToTarget is dx1 or dxN
%
% This is simple linear algebra that YOU SHOULD KNOW!
%
% Sanity check:
% theta = linspace(0,2*pi,100);
% v = [cos(theta); sin(theta)]; % velocities are on unit circle
% targetDirection = [1;0]; % unit vector along x-axis
% progress_i = computeProgressOfProjection(v,targetDirection);
% plot(theta,progress_i); % progress_i = cos(theta) = v(1,:) = x-value
%
% @ Matt Golub, 2018.

[d,T1] = size(v);
[d,T2] = size(cursorToTarget);

% This can be factored out for efficiency, but probably not worth the
% debugging effort in the case that I ever forget to pre-normalize
targetDirection = normalizeColumns(cursorToTarget);

if T1==1 || T2==1
    progress = targetDirection'*v;
else
    progress = sum(v.*targetDirection,1); % same as diag(targetDirection'*v);
end
angles = acosd(progress./columnNorms(v));

end