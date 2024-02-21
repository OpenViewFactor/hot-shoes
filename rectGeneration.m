% RECTANGLEGENERATION generates a uniformly refined rectangular mesh
%
% INPUTS:
% bbox : bounding box [xmin, xmax; ymin, ymax; zmin, zmax]
% dir : direction of normal vector [xdir, ydir, zdir]
% scale : scalar refinement factor for distmesh -> higher is more refined
%
% OUTPUTS:
% outMesh : output triangulation

% NOTE: - this is strictly for generating rectangles with edges along the cardinal planes
%       - further coordinate transformations can be applied for modifications like rotation
%       - for simplicity, one edge is assumed to lie parallel to the z-axis

function outMesh = rectGeneration(bbox,direc,scale)

xmin = bbox(1,1);
xmax = bbox(1,2);
xlen = xmax - xmin;

ymin = bbox(2,1);
ymax = bbox(2,2);
ylen = ymax - ymin;

horizontalEdge = [xlen, ylen, 0];
horizLen = norm(horizontalEdge);

zmin = bbox(3,1);
zmax = bbox(3,2);
zlen = abs(zmax - zmin);

vertEdge = [0, 0, zlen];
vertLen = norm(vertEdge);

e1 = horizontalEdge ./ horizLen;
e2 = vertEdge ./ vertLen;

OA3d = [xmin,ymin,zmin];
OB3d = [xmax,ymax,zmin];
OC3d = [xmax,ymax,zmax];
OD3d = [xmin,ymin,zmax];

normalVector = cross(OB3d - OA3d, OD3d - OA3d)./norm(cross(OB3d - OA3d, OD3d - OA3d));

% project the 3D bounding box into a 2D plane

  % define vertices of rectangle in 2D plane
  OA2d = [0, 0];
  OB2d = [horizLen, 0];
  OC2d = [horizLen, vertLen];
  OD2d = [0, vertLen];

  bbox2d = [0, 0; horizLen, vertLen]; % new bounding box in 2D plane

% run distmesh in 2D plane
[pos2d, pointers] = distmesh2d(@drectangle, @huniform, min([horizLen, vertLen])/scale, bbox2d,[OA2d;OB2d;OC2d;OD2d], [0,horizLen,0,vertLen]);

% project back into 3D cartesian space

  % pos2d(:,1) -> length along horizontal edge in x-y plane
  % pos2d(:,2) -> z coords in 3D cartesian space

  pos3d = [e1(1,1:2).*pos2d(:,1) + OA3d(1:2), e2(1,3).*pos2d(:,2) + OA3d(3)];

% package into outMesh triangulation
outMesh = triangulation(pointers, pos3d);

% check normals -> flip
if ~vecEq(direc./norm(direc), normalVector, 0.0001) && ~vecEq(direc./norm(direc), [0,0,0], 0.0001)
  outMesh = flipNormals(outMesh);
end