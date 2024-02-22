% ----- Distance Function for Rectangular Regions ----- %

% Function Description:
%   rect_distfun.m determines the signed distance for each point in a list p.
%   points within the triangle are denoted with a negative distance by convention.

% Function Parameters:
%   [] p : a list of points to evaluate
%   [] v : cell array of rectangle vertices
%   [] rOA : vertex OA of the rectange
%   [] rOB : vertex OB of the rectange
%   [] rOC : vertex OC of the rectange
%   [] rOD : vertex OD of the rectangle

% Function Output:
%   [] d : signed distance values for each point in the list

function d = rect_distfun(p, v)

  rOA = v{1}; rOB = v{2}; rOC = v{3}; rOD = v{4};
  
  nP = size(p, 1);  % number of points
  p = [p, zeros(nP, 1)];
  rOA = [rOA, 0]; rOB = [rOB, 0]; rOC = [rOC, 0]; rOD = [rOD, 0];
  d1 = point_to_line(p, rOA, rOB); d2 = point_to_line(p, rOB, rOC); d3 = point_to_line(p, rOC, rOD); d4 = point_to_line(p, rOD, rOA);
  d = min([d1, d2, d3, d4], [], 2);
  inside = inside_rectangle(p, rOA, rOB, rOC, rOD);
  d(inside) = -d(inside);
  d(abs(d) < eps) = 0;  % test for distance < machine precision

end