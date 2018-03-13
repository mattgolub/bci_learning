function clouds = reconstructPostLearningClouds(LP_clouds,simL,expParams)
% Take raw simulated data in matrix form and reconstruct into the LP_clouds
% format. Overwrite simulated cursor-to-target direction (which are
% condition-averaged) with timestep-by-timestep values from LP_clouds.
% Cursor progress is recomputed based on these timestep-by-timestep
% directions.

intuitiveCursorParams = expParams.intuitiveMapping;
perturbedCursorParams = expParams.perturbedMapping;

spikes = simL.X;
factorActivity = simL.Z;
cloudIDs = simL.C;
numConditions = max(cloudIDs);

cursorToTargetDirection = nan(size(simL.D)); % don't copy condition-averaged cTTD
for cIdx = 1:numConditions
    idx = cloudIDs==cIdx;
    cursorToTargetDirection(:,idx) = LP_clouds.cursorToTargetDirection{cIdx};
end

dt = intuitiveCursorParams.dt;

% Some formatting hacks to mesh with previously-written code {}
concat.orthonormalizedFactorActivity = {factorActivity};
[intuitivePlaneActivity, vraw_intuitive] = computeControlPlaneActivity(concat,intuitiveCursorParams);
[perturbedPlaneActivity, vraw_perturbed] = computeControlPlaneActivity(concat,perturbedCursorParams);

% Some formatting hacks to mesh with previously-written code {1}
intuitivePlaneActivity = intuitivePlaneActivity{1};
vraw_intuitive = vraw_intuitive{1};
perturbedPlaneActivity = perturbedPlaneActivity{1};
vraw_perturbed = vraw_perturbed{1};

intuitiveProgress = computeProgressOfProjection(vraw_intuitive,cursorToTargetDirection)*dt;
perturbedProgress = computeProgressOfProjection(vraw_perturbed,cursorToTargetDirection)*dt;
cursorProgress = perturbedProgress; % dt already taken care of above

% There can be a silly issue here with the ordering of fieldnames when
% combining clouds into an array (in run_simulatedLearning).
% fnames = fieldnames(LP_clouds);

fnames = {'factorActivity','cursorToTargetDirection','spikes','cursorProgress',...
    'intuitiveProgress','perturbedProgress',...
    'intuitivePlaneActivity','vraw_intuitive',...
    'perturbedPlaneActivity','vraw_perturbed'};

for fIdx = 1:numel(fnames)
    fname = fnames{fIdx};
    data = eval(fname);
    for cIdx = 1:numConditions
        idx = cloudIDs==cIdx;
       clouds.(fname){cIdx} = data(:,idx);
    end
end
clouds.angles = LP_clouds.angles;
clouds.windowIdx = [];

end