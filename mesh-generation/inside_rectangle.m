% ----- Interior Determination for Rectangles ----- %

% Function Description:
%   inside_rectangle.m determines whether each point in the list `p` is within the boundary
%   of the rectangle, specified by its four vertices `rOA`, `rOB`, `rOC`, `rOD`

% Function Parameters:
%   [] p : a list of points to evaluate
%   [] rOA : vertex OA of the rectange
%   [] rOB : vertex OB of the rectange
%   [] rOC : vertex OC of the rectange
%   [] rOD : vertex OD of the rectangle

% Function Output:
%   [] inside : boolean array to signal whether each point in p is within the rectangle

function inside = inside_rectangle(p, rOA, rOB, rOC, rOD)
  v_size = @(a, b) ones(size(b,1),3) .* a;  % replicates vector a to match the size of b
  pA = p - v_size(rOA, p); pB = p - v_size(rOB, p); pC = p - v_size(rOC, p); pD = p - v_size(rOD, p);
  pApB = cross(pA, pB); pBpC = cross(pB, pC); pCpD = cross(pC, pD); pDpA = cross(pD, pA);
  inside = all([sign(pApB(:,3)) == sign(pBpC(:,3)),...
                sign(pApB(:,3)) == sign(pCpD(:,3)),...
                sign(pApB(:,3)) == sign(pDpA(:,3)),...
                sign(pBpC(:,3)) == sign(pCpD(:,3)),...
                sign(pBpC(:,3)) == sign(pDpA(:,3)),...
                sign(pCpD(:,3)) == sign(pDpA(:,3))], 2);
end