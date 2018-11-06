function [ x, dif, iter ] = myMLS( A, b, tol, MaxIter)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%   A: well A is A
%   b: store the target amplitude and initial phase estimate of the target
%   tol: the target tolerence of the optimisation
%   MaxIter: the maximum number of iteration

tol_b = max(abs(b(:))).*tol;
b0 = abs(b);
pinvA = pinv(A);
x = pinvA*b;
dif = abs(A*x)-b0;

iter = 1;
while (norm(dif,2)>tol_b) && iter<MaxIter
	z = exp(1i.*phase(A*x));
	x = pinvA*(b0.*z);
	dif = abs(A*x)-b0;
	iter = iter + 1;
end

