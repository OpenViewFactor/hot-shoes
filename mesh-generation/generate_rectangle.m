% RECTANGLEGENERATION generates a uniformly refined rectangular mesh
%
% INPUTS:
% v : array of 4 3-D vertices [v1; v2; v3; v4] in clockwise order such that the
%            normal vector, as defined by right-hand rule, is oriented as intended
% scale : scalar refinement factor for distmesh -> higher is more refined
%
% OUTPUTS:
% oM : output triangulation

% NOTE: - this is strictly for generating rectangles with edges along the cardinal planes
%       - further coordinate transformations can be applied for modifications like rotation
%       - for simplicity, one edge is assumed to lie parallel to the z-axis

function oM = generate_rectangle(v, scale)

  v1 = v(1,:); v2 = v(2,:); v3 = v(3,:); v4 = v(4,:);
  origin = v1;

  % project 3D coordinates into 2D plane
  [v1_2d, v2_2d, v3_2d, v4_2d, A] = replane(v1, v2, v3, v4);
  rC = (v1_2d + v2_2d + v3_2d + v4_2d) ./ 4;  % 2D centroid

  % run distmesh in 2D plane
  h0 = abs(rect_distfun(rC, {v1_2d, v2_2d, v3_2d, v4_2d})) / double(scale);
  bbox = [min([v1_2d(1), v2_2d(1), v3_2d(1), v4_2d(1)]),...
          min([v1_2d(2), v2_2d(2), v3_2d(2), v4_2d(2)]);...
          max([v1_2d(1), v2_2d(1), v3_2d(1), v4_2d(1)]),...
          max([v1_2d(2), v2_2d(2), v3_2d(2), v4_2d(2)])];
  [oP2D, oC] = distmesh2d(@rect_distfun,...
                          @huniform,...
                          h0,...
                          bbox,...
                          [v1_2d; v2_2d; v3_2d; v4_2d],...
                          {v1_2d, v2_2d, v3_2d, v4_2d});

  % project 2D output points back into 3D cooordinates
  oP3D = [oP2D, zeros(length(oP2D(:,1)),1)];
  oP3D = origin + transpose(A*transpose(oP3D));
  oM = triangulation(oC, oP3D);

end