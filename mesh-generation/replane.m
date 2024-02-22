% ----- Application of `distmesh2d` to a specific triangle ----- %

% Function Description:
%   Triangles are redefined from their natural 3D cartesian coordinates into
%   the 2D plane of the surface itself with coordinates along the axes of that triangle.

% Function Parameters:
%   [] rOA : vertex OA of the triangle
%   [] rOB : vertex OB of the triangle
%   [] rOC : vertex OC of the triangle

% Function Output:
%   [] rOA : transformed vertex OA of the triangle
%   [] rOB : transformed vertex OB of the triangle
%   [] rOC : transformed vertex OC of the triangle
%   [] A : coordinate transformation matrix

function [rOA, rOB, rOC, rOD, A] = replane(rOA, rOB, rOC, rOD)

  eAB = rOB - rOA; eBC = rOC - rOB; eCD = rOD - rOC; eDA = rOA - rOD;
  rE = [eAB; eBC; eCD; eDA];                                    % organize the edges of triangle `i`
  [~, maxLoc] = max(sqrt(sum(rE .* rE, 2)));                    % find the longest edge
  switch maxLoc                                                 % reorganize longest edge as the base
    case 2
      eAB = eBC; eBC = eCD;
    case 3
      eAB = eCD; eBC = eDA;
    case 4
      eAB = eDA; eBC = rOB - rOA;
  end

  % new planar basis vectors
  e1 = eAB(1,:) ./ norm(eAB(1,:));
  e2 = (eBC(1,:) - (dot(eBC(1,:), e1, 2) * e1)) ./...
      norm(eBC(1,:) - (dot(eBC(1,:), e1, 2) * e1));
  e3 = cross(e1, e2);

  % coordinate transformation matrix
  A = [e1', e2', e3'];
  bA = rOA' - rOA(1,:)';                                  % all points A relative to one point
  bB = rOB' - rOA(1,:)';                                  % all points B relative to one point
  bC = rOC' - rOA(1,:)';                                  % all points C relative to one point
  bD = rOD' - rOA(1,:)';                                  % all points D relative to one point

  % apply coordinate transformation
  rOA = (A\bA)';
  rOB = (A\bB)';
  rOC = (A\bC)';
  rOD = (A\bD)';

  % z = 0 for all points in new basis -> make it 2D
  rOA(:,3) = []; rOB(:,3) = []; rOC(:,3) = []; rOD(:,3) = [];

end