% This script runs the codepack that accompanies "Learning by neural  
% reassociation," by Matthew D. Golub, Patrick T. Sadtler , Emily R. Oby, 
% Kristin M. Quick, Stephen I. Ryu, Elizabeth C. Tyler-Kabara, Aaron P. 
% Batista, Steven M. Chase, and Byron M. Yu. Nature Neuroscience, 2018.
%
% Codepack version: 1.0
%
% Please check for updates, as frequent improvements are being made through
% March 2018. If you would like notifications about updates, please direct
% such a request to Matt Golub (mgolub@stanford.edu). Feedback, comments, 
% suggestions, bug reports, etc, are also welcomed and encouraged.
%
% SETUP: 
%
% To run the codepack, you must download CVX for Matlab from
% www.cvxr.com/cvx/. Place the uncompressed "CVX" folder inside the
% top-level folder of this codepack.
%
% KNOWN ISSUES:
%
% This codepack may not function properly with Matlab versions beyond
% R2015a. This is due to compatibility issues with CVX (see above). We are
% actively working to resolve these issues.
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