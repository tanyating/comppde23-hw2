function Solution = sol_motz(x);
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

% since expansion solution is in spherical coordinates, convert.
[theta,r] = cart2pol(X,Y);

Solution = zeros(length(X),1);

% coeffs for asymptotic expansion of Motz problem

A=[
401.162453745234416 
87.6559201950879299
17.2379150794467897
-8.0712152596987790
1.44027271702238968
0.331054885920006037
0.275437344507860671
-0.869329945041107943e-1
0.336048784027428854e-1
0.153843744594011413e-1
0.730230164737157971e-2
-0.318411361654662899e-2
0.122064586154974736e-2
0.530965295822850803e-3
0.271512022889081647e-3
-0.120045043773287966e-3
0.505389241414919585e-4
0.231662561135488172e-4
0.115348467265589439e-4
-0.529323807785491411e-5
0.228975882995988624e-5
0.106239406374917051e-5
0.530725263258556923e-6
-0.245074785537844696e-6
0.108644983229739802e-6
0.510347415146524412e-7
0.254050384217598898e-7
-0.110464929421918792e-7
0.493426255784041972e-8
0.232829745036186828e-8
0.115208023942516515e-8
];

% evaluate expansion
for k = 1:30
   Solution = Solution + A(k)*r.^(0.5*(2*k-1)).*cos(0.5*(2*k-1).*theta);
end

