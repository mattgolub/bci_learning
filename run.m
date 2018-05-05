% This script runs the codepack that accompanies "Learning by neural  
% reassociation," by Matthew D. Golub, Patrick T. Sadtler , Emily R. Oby, 
% Kristin M. Quick, Stephen I. Ryu, Elizabeth C. Tyler-Kabara, Aaron P. 
% Batista, Steven M. Chase, and Byron M. Yu. Nature Neuroscience, 2018.
%
% Thanks to Jay Hennig and Emily Oby for helpful feedback on the codepack.
%
% Codepack version: 1.1
% 
% Feedback, comments, suggestions, bug reports, etc, are welcomed and encouraged.
% Please direct correspondence to Matt Golub (mgolub@stanford.edu).
%
% SETUP: 
%
% To run the codepack, you must download CVX for Matlab from
% www.cvxr.com/cvx/. Place the uncompressed "cvx" folder inside the
% top-level folder of this codepack.
%
% MATLAB VERSIONS:
%
% This codepack was developed and tested using Matlab R2015a. We have also 
% had success with Matlab R2013a, R2016a, and R2017b. This codepack may not 
% be compatible with earlier Matlab versions (e.g., not compatible with 
% R2011b).
%
% DESCRIPTION:
%
% This codepack includes:
% 1) The optimization routines used to predict after-learning neural 
% activity and behavior according to the 5 hypotheses described in the 
% paper: realignment, rescaling, reassociation, partial realignment, and 
% subselection.
%
% 2) The primary analysis routines used to compare the experimental data to 
% the predictions of the aforementioned hypotheses. These analyses include
% repertoire visualization (as in Fig. 3), repertoire change (as in Fig.
% 4b), covariability along the BCI mappings (as in Fig. 5c), changes in 
% variance vs changes in pushing magnitude (as in Fig. 6f), behavior (as in
% Fig. 7), and movement-specific repertoire change (as in Fig. 8c).
%
% 3) Data from a representative experiment (monkey J, 20120305).
%
% Running this script will, for the representative data,  generate the 
% predicted neural activity (from 1, above), run the analyses (from 2, 
% above), and generate figures that correspond to these analyses and 
% parallel the paper's main figures.
%
% @ Matt Golub, 2018.

clearvars
close all

%% Set up the paths to the files included in the codepack.
addpaths

%% This sets up CVX, a convex optimization package that is used, alongside
% some Matlab built-in optimizers, to generate the predicted neural
% activity according to each of the paper's 5 hypotheses.
% See IMPORTANT note above for details on downloading and installing CVX.
cvx_setup % This line only needs to be run once and can be commented out thereafter.

%% Load data from the representative experiment.
load exampleData.mat

% The workspace now contains the following 3 variables: beforeLearning, 
% afterLearning, and expParams.
%
% beforeLearning:
%   A struct containing data from the 'before learning' trials of the 
%   example experiment, which we defined as the last 50 trials under the 
%   intuitive BCI mapping.
%       .name: 'Data' because that's what we're talking about.
%       .clouds: Data grouped into 8 movement-specific clouds. Most fields
%          here are 8-element cell arrays, with cell{i} containing data
%          from timesteps when the cursor-to-target direction was closer to
%          .angles(i) than to any other element of .angles. A single trial
%          can contribute data to multiple movement-specific clouds (if
%          the cursor movement from that trial is not straight). In these
%          8-element cell arrays, each cell contains an N-column matrix (in
%          this experiment, N=71). In these matrices, each column (indexed
%          by j in descriptions below) represents a single non-overlapping 
%          45ms timestep.
%
%           .factorActivity{i}(:,j): 10D 'population activity pattern', 
%              defined mathematically as \hat{z}_t^{orth} in equation 15.
%           .cursorToTargetDirection{i}(:,j): 2D unit vector in the
%              straight-to-target direction from the current cursor 
%              position.
%           .spikes{i}(:,j): q-dimensional vector of spike counts (here 
%              q=86), which maps to .factorActivity{i}(:,j) after z-scoring
%              and dimensionality reduction via factor analysis.
%           .vraw_intuitive{i}(:,j): 2D single-timestep cursor velocity
%              computed by passing .factorActivity{i}(:,j) through the
%              intuitive BCI mapping. This corresponds to equation
%              4, but replacing B^{pert} with B (i.e., the intuitive
%              mapping, not the perturbed mapping).
%           .vraw_perturbed{i}(:,j): 2D single-timestep cursor velocity
%              computed by passing .factorActivity{i}(:,j) through the
%              perturbed BCI mapping. This corresponds to equation 4.
%           .intuitiveProgress{i}(:,j): The projection of
%              .vraw_intuitive{i}(:,j) onto .cursorToTargetDirection{i}(:,j).
%           .perturbedProgress{i}(:,j): The projection of
%              .vraw_perturbed{i}(:,j) onto .cursorToTargetDirection{i}(:,j).
%           .cursorProgress: Because the intuitive mapping was in place
%              during the before-learning trials, this is exactly
%              .intuitiveProgress.
%       .angles: The 8 center-to-target angles (in degrees).
%       .windowIdx: Trial numbers of the trials from which these data
%           originated.
%
% afterLearning:
%   A struct with the same format as beforeLearning, but with data from the
%   'after learning' trials, which we defined as the successful trials from 
%   the 50 consecutive perturbation trials that showed the best behavioral 
%   performance (see Methods). Here, .cursorProgress is exactly
%   .perturbedProgress (because the perturbed mapping was in place during
%   the after-learning trials).
%
% expParams:
%   A struct containing the following details from the example experiment:
%       .monkName: The animals's name.
%       .expDate: The experiment date.
%       .intuitiveMapping: Struct containing components of the intuitive
%           BCI mapping. Note: naming conventions here do not always match
%           those from the paper.
%       .perturbedMapping: Struct containing components of the perturbed
%           BCI mapping. Naming conventions match those in .intuitiveMapping.
%       .lambda: Scalar multiplier used to match predicted and actual 
%           mean acquisition times from the after-learning trials. This is
%           \lambda_{after}^{pert} in equation 9.


%% Perform analyses on the data from the representative experiment.
afterLearning.metrics = computePopulationMetrics(beforeLearning,afterLearning,expParams);

%% Predict after-learning neural activity according to the 5 hypotheses

hypothesisNames = {...
    'Realignment',...
    'Rescaling',...
    'Reassociation',...
    'Partial realignment',...
    'Subselection'};
nHypotheses = numel(hypothesisNames);

for hypIdx = 1:nHypotheses
    hypotheses(hypIdx) = generateHypothesisPredictions(hypothesisNames{hypIdx},beforeLearning,afterLearning,expParams);
end

%% Perform analyses on each hypothesis' predicted neural activity

for hypIdx = 1:nHypotheses
    hypotheses(hypIdx).metrics = computePopulationMetrics(beforeLearning,hypotheses(hypIdx),expParams);
end

%% Generate figures 
% Figure numbers here correspond to figure numbers in the paper.

% Visualizing activity patterns through the perturbed BCI mapping
figure(3); clf;
plotFigure3(beforeLearning,afterLearning);

% These main hypotheses (as illustrated in Fig. 2) are featured Figs. 4-7.
mainHypothesesIdx = [1 2 3]; % realignment, rescaling, and reassociation

% Repertoire change
figure(4); clf;
plotFigure4(afterLearning,hypotheses(mainHypothesesIdx))

% Change in covariance along BCI mappings
figure(5); clf;
plotFigure5(afterLearning,hypotheses(mainHypothesesIdx));

% Change in variance vs change in pushing magnitude
figure(6); clf;
plotFigure6(afterLearning,hypotheses(mainHypothesesIdx));

% Predicted behavior
figure(7); clf;
plotFigure7(afterLearning,hypotheses(mainHypothesesIdx))

% Movement-specific repertoire change, addressing partial realignment and subselection
figure(8); clf;
plotFigure8(afterLearning,hypotheses);
