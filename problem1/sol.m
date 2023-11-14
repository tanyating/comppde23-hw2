function VolumeForce = sol(x);
%   Exact solution
%   Y = F(X) returns values of forces at N discrete points in the considered
%   domain. This input data has to be chosen by the user. X has dimension N
%   x 2 and Y has dimension N x 1.
%
%
%   See also FEM2D, U_D, and G.

%    J. Alberty, C. Carstensen and S. A. Funken  02-11-99
%    File <f.m> in $(HOME)/acf/fem2d/
%    This volume force is used to compute Fig. 3 in 
%    "Remarks around 50 lines of Matlab: Short finite element 
%    implementation".

X = x(:,1);
Y = x(:,2);
VolumeForce = zeros(size(X));
VolumeForce(X>0) = 500;
