clear;
%FEM2D   two-dimensional finite element method for Laplacian.
%
%    FEM2D solves Laplace's equation 
%      - div(grad(u)) = f in Omega
%                   u = u_D on the Dirichlet boundary
%              d/dn u = g   on the Neumann boundary
%    on a geometry described by triangles and parallelograms, respectively
%    and presents the solution graphically.
% 
%    Therefore, FEM2D assembles plane Courant finite elements and calculates
%    a discrete right-hand side as the coefficient vector of the affine
%    element approximation. Volume force and boundary data are given as
%    M-files <f.m>, <g.m>, and <u_d>. FEM2D uses the reduced linear system 
%    of equations to calculate a discrete solution of the Laplace-problem. 
%    The resulting piecewise affine approximation will be graphically 
%    represented.
% 
%    FEM2D loads the mesh data from data-files. The program reads the
%    triangular and/or quadrilateral elements from the files <elements3.dat>
%    and/or <elements4.dat>, respectively. Depending on the mesh one of the
%    two files, but not both, can be omitted. The first column in
%    <elements3.dat> and <elements4.dat> gives the number of each
%    element. This is used for clearness and is not neccesary for the
%    numerical algorithm. The following columns give the number of each
%    node. Nodes of elements are counted anti-clockwise.
% 
%    To adapt the program to a given Laplace equation the user has to
%    specify the data-files <coordinates.dat>, <elements3.dat> and/or
%    <elements4.dat>, <dirichlet.dat>, and <neumann.dat> (optional) and the
%    M-files <f.m>, <u_d.m>, and <g.m> (optional). They have to be in the
%    same directory as <fem2d.m>.
%
%    Remark: This program is a supplement to the paper "Remarks around  
%    50 lines of Matlab: Short finite element implementation" by  
%    J. Alberty, C. Carstensen and S. A. Funken. The reader should 
%    consult that paper for more information.   
%
%
%    M-files you need to run FEM2D
%       <stima3.m>, <stima4.m>, <f.m>, <u_d.m>, <show.m> and <g.m> (optional)
%
%    Data-files you need to run FEM2D
%       <coordinates.dat>, <elements3.dat> and/or <elements4.dat>,
%       <dirichlet.dat>, and <neumann.dat> (optional)

%    J. Alberty, C. Carstensen and S. A. Funken  02-11-99
%    File <fem2d.m> in $(HOME)/acf/fem2d/
%    This program and corresponding data-files give Fig. 3 in 
%    "Remarks around 50 lines of Matlab: Short finite element 
%    implementation"

addpath('/Users/ting/comppde23-hw2/problem-motz');

% Initialisation
load coordinates.dat; coordinates(:,1)=[];
eval('load elements3.dat; elements3(:,1)=[];','elements3=[];');
eval('load elements4.dat; elements4(:,1)=[];','elements4=[];');
eval('load neumann.dat; neumann(:,1) = [];','neumann=[];');
load dirichlet.dat; dirichlet(:,1) = [];

k = 15; % number of times refining
L2_errors = zeros(k,1); % store L2-norm of error
Ns = zeros(k,1); % store number of elements
residual_dec = cell(k,1); % store error indicators in descending order

%% refines the mesh uniformly several times
for i=1:k
   if i>1
   [coordinates,elements3,dirichlet,neumann] ...
       = refineRGB(coordinates,elements3,dirichlet,neumann,mark_idx);
    end


FreeNodes=setdiff(1:size(coordinates,1),unique(dirichlet));
A = sparse(size(coordinates,1),size(coordinates,1));
b = sparse(size(coordinates,1),1);

% Assembly
for j = 1:size(elements3,1)
  A(elements3(j,:),elements3(j,:)) = A(elements3(j,:),elements3(j,:)) ...
      + stima3(coordinates(elements3(j,:),:));
end
for j = 1:size(elements4,1)
  A(elements4(j,:),elements4(j,:)) = A(elements4(j,:),elements4(j,:)) ...
      + stima4(coordinates(elements4(j,:),:));
end

% Volume Forces
for j = 1:size(elements3,1)
  b(elements3(j,:)) = b(elements3(j,:)) + ...
      det([1,1,1; coordinates(elements3(j,:),:)']) * ...
      f(sum(coordinates(elements3(j,:),:))/3)/6;
end
for j = 1:size(elements4,1)
  b(elements4(j,:)) = b(elements4(j,:)) + ...
      det([1,1,1; coordinates(elements4(j,1:3),:)']) * ...
      f(sum(coordinates(elements4(j,:),:))/4)/4;
end

% Neumann conditions
for j = 1 : size(neumann,1)
  b(neumann(j,:))=b(neumann(j,:)) + norm(coordinates(neumann(j,1),:)- ...
      coordinates(neumann(j,2),:)) * g(sum(coordinates(neumann(j,:),:))/2)/2;
end

% Dirichlet conditions 
u = sparse(size(coordinates,1),1);
u(unique(dirichlet)) = u_d(coordinates(unique(dirichlet),:));
b = b - A * u;

% Computation of the solution
u(FreeNodes) = A(FreeNodes,FreeNodes) \ b(FreeNodes);

% graphic representation
% figure();
% show(elements3,elements4,coordinates,full(u));

% L2 error of difference to exact solution
L2norm = 0;
for j = 1:size(elements3,1)
    d = (sol_motz(sum(coordinates(elements3(j,:),:))/3)-sum(u(elements3(j,:),:))/3)/6;
    L2norm = L2norm + ...
      d'*det([1,1,1; coordinates(elements3(j,:),:)']) * d;
end

fprintf('|u-u_h|_L2 = %f2\n', sqrt(L2norm));

L2_errors(i) = sqrt(L2norm);
% Ns(i) = length(elements3);
Ns(i) = length(coordinates)^0.5-1;

indicators = computeEtaR(u,coordinates,elements3,dirichlet,neumann,@f,@g);
[ind_sort,idx]=sort(indicators,'descend');
residual_dec{i} = ind_sort;
mark_idx = idx(1:ceil(length(idx)/10)); % mark elements with top 10% residuals


end

figure();
plot(log(Ns), log(L2_errors), 'bo--','Linewidth',1,'Markersize',5);
% loglog(Ns, L2_errors, 'bo--','Linewidth',1,'Markersize',5);
% set(gca,'XScale','log')
% set(gca,'YScale','log')
xlabel('(log) N number of elements');
ylabel('(log) |u-u_h|_L2');
% axis equal
title('loglog plot of L2-errors vs. mesh size (1/h)');

figure(); hold on;
picked = [13,14,15];
ls = cell(length(picked),1); % Initialize array  with legends
li = 1;
for i=picked
    plot(residual_dec{i},'o--','Linewidth',1,'Markersize',5);
    % Save legend entry
    ls{li} = [num2str(length(residual_dec{i})), ' elements'];
    li = li+1;
end
legend(ls, 'Interpreter', 'none');
set(gca,'XScale','log')
set(gca,'YScale','log')
xlabel('(log) estimated errors');
ylabel('(log) elements');
% axis equal
title('loglog plot of the error indicators');
