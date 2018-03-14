This script runs the codepack that accompanies "Learning by neural  
reassociation," by Matthew D. Golub, Patrick T. Sadtler , Emily R. Oby, 
Kristin M. Quick, Stephen I. Ryu, Elizabeth C. Tyler-Kabara, Aaron P. 
Batista, Steven M. Chase, and Byron M. Yu. Nature Neuroscience, 2018.

Thanks to Jay Hennig and Emily Oby for helpful feedback on the codepack.

Codepack version: 1.0

Please check for updates, as frequent improvements are being made through
March 2018. If you would like notifications about updates, please direct
such a request to Matt Golub (mgolub@stanford.edu). Feedback, comments, 
suggestions, bug reports, etc, are also welcomed and encouraged.

SETUP: 

To run the codepack, you must download CVX for Matlab from
www.cvxr.com/cvx/. Place the uncompressed "cvx" folder inside the
top-level folder of this codepack.

MATLAB VERSIONS:

This codepack was developed and tested using Matlab R2015a. We have also 
had success with Matlab R2013a, R2016a, and R2017b. This codepack may not 
be compatible with earlier Matlab versions (e.g., not compatible with 
R2011b).

DESCRIPTION:

This codepack includes:
1) The optimization routines used to predict after-learning neural 
activity and behavior according to the 5 hypotheses described in the 
paper: realignment, rescaling, reassociation, partial realignment, and 
subselection.

2) The primary analysis routines used to compare the experimental data to 
the predictions of the aforementioned hypotheses. These analyses include
repertoire visualization (as in Fig. 3), repertoire change (as in Fig.
4b), covariability along the BCI mappings (as in Fig. 5c), changes in 
variance vs changes in pushing magnitude (as in Fig. 6f), behavior (as in
Fig. 7), and movement-specific repertoire change (as in Fig. 8c).

3) Data from a representative experiment (monkey J, 20120305).

Running this script will, for the representative data,  generate the 
predicted neural activity (from 1, above), run the analyses (from 2, 
above), and generate figures that correspond to these analyses and 
parallel the paper's main figures.

@ Matt Golub, 2018.
