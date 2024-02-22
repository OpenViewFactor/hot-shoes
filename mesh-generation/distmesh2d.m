%% distmesh - from Per-Olf Persson and Gilbert Strang
% NOTE: some variables have been renamed from the original for more clarity

% function OUTPUTS
%   {pos} - node positions in an Nx2 array with x-y coordinates of each node
%   {triangulation} - triangle connections list, similar to the ConnectiviyList in a triangulation structure

% function INPUTS
%   {distFunction} : geometry is given as a distance function - returns the signed distance from each node location p to the closest boundary
%   {hFun} : (relative) desired edge length function {hFun} = h(x,y) - could be a scalar but could also be some function of x, y
%   {h0} : gives the distance between points initialized in the first distribution (see step 1)
%   {bbox} : bounding box for the region is an array {bbox} = [xmin, ymin; xmax, ymax]
%   {pFix} : positions of the fixed nodes are given as an array {pFix} (subset of {pos}) any additional parameters to the functions {distFunction} and {hFun} can be specified in varargin

function [pos, triangulation] = distmesh2d(distFunction, hFun, h0, bbox, pFix, varargin)

%   will comment with descriptions as the utility for each of these is determined - still working on it
dptol = 0.0001;
ttol = 0.001;
Fscale = 1.2;   % scale factor for the forces
deltat = 0.1;
geps = 0.001 * h0;  % small fraction of h0
deps = sqrt(eps) * h0;  % a REALLY small number [sqrt(2.2e-16) * h0]

% 1. Create initial distribution in bounding box (equilateral triangles)
%   initialize a rectangular grid of dots within the overall bounding box of the mesh
%   shift every point in every second row by h0/2 to form equilateral triangles
%   store x,y for each node in the position vector, p

[x, y] = meshgrid( bbox(1, 1):h0:bbox(2, 1) , bbox(1, 2):h0*sqrt(3)/2:bbox(2, 2) );
x( 2:2:end, : ) = x( 2:2:end, : ) + h0/2;
pos = [ x(:) , y(:) ];

% 2. Remove points outside the region, apply the rejection method
%   evaluate the geometry function {distFunction} for every node in {p} and eliminate any points that are more than geps away from a boundary (remember, d > 0 outside the geometry)
%   r0 = 1 / ( h(x,y)^2 ) - probability that each point in {p} is kept
%   new list of nodes {p} contains all fixed nodes and any other nodes kept by probability
%   Number of nodes is the number of rows in {p}

pos = pos( feval( distFunction, pos, varargin{:} ) < geps, : );
r0 = 1./feval( hFun, pos, varargin{:} ).^2;
pos = [ pFix; pos( rand( size( pos, 1 ), 1 ) < r0./max(r0), : ) ];
pos = unique(pos, 'rows', 'stable');
N = size( pos, 1 );

oldPos = inf; % set oldPos to infinity for the first iteration (gets redefined every iteration)
while 1
    
    % 3. Retriangulation by the Delaunay algorithm
    %   compare the maximum motion of the nodes from the previous iteration to {ttol}
    if max( sqrt( sum( ( pos - oldPos ).^2, 2 ) ) / h0 ) > ttol
        %   save current positions in {oldPos} before modifying them
        %   return the Delaunay triangulation of the set of points given in {pos} into {triangulation}
        %   compute the centroids of each triangle in {triangulation}
        %   eliminate any centroids not within {geps} inside the boundary
        
        pos = unique(pos, 'rows', 'stable');
        oldPos = pos;
        triangulation = delaunayn( pos );
        pCents = ( pos( triangulation( :, 1 ), : ) + pos( triangulation( :, 2 ), : ) + pos( triangulation( :, 3 ), : )) / 3;
        triangulation = triangulation( feval( distFunction, pCents, varargin{:} ) < -geps, : );
        
        % 4. Describe each bar by a unique pair of nodes
        %   {bars} denotes connections between every pair of nodes and has size something like : (3N)x(2)
        %   eliminate any duplicates (there are many) in {bars}
        
        bars = [ triangulation( :, [ 1, 2 ] ); triangulation( :, [ 1, 3 ] ); triangulation( :, [ 2, 3 ] ) ];
        bars = unique( sort( bars, 2 ), 'rows');
        
        
    end
    % 5. Graphical output of the current mesh
%     figure(1)
%     trimesh( triangulation, pos( :, 1 ), pos( :, 2 ), zeros( (length(pos(:,1))) , 1 ) )
%     view(3)
%     axis equal
%     drawnow
    
    % 6. Move meshpoints based on bar lengths L and forces F
    %   convert nodes in {bars} into the cartesian vectors corresponding to each bar
    %   store the lengths of every bar in {bars} into {barLenghts}
    %   averages h(x,y) for the two nodes of each bar to be used in scaling the bar
    %   {L0} returns the desired lengths for each bar in {bars} by scaling according to the root-square of {barLengths} per {hFun}.
    %   returns scalar forces acting through each bar in {F} - zero for lengths already less than {L0}
    %   converts the scalar forces in {F} into vectors in {Fvec} by splitting it into the unit direction vector along {barVec}
    %   some kind of a total force in the bridge (?)
    %   set the force for fixed bars (according to {pFix}) to zero
    %   adjust positions according to {Ftot} scaled by {deltat} parameter
    
    barVec = pos( bars( :, 1 ), : ) - pos( bars( :, 2 ), : );
    barLengths = sqrt( sum( barVec.^2, 2) );
    hbars = feval( hFun, ( pos(bars( :, 1 ), : ) + pos( bars( :, 2 ), : ) ) / 2, varargin{:} );
    L0 = hbars * Fscale * sqrt( sum( barLengths.^2 ) / sum( hbars.^2 ) );
    F = max( L0 - barLengths, 0 );
    Fvec = F./barLengths * [ 1, 1 ].*barVec;
    Ftot = full( sparse( bars( :, [ 1, 1, 2, 2 ] ), ones( size( F ) ) * [ 1, 2, 1, 2 ], [ Fvec, -Fvec ], N , 2 ) );
    Ftot( 1:size( pFix, 1 ), : ) = 0;
    pos = pos + deltat * Ftot;
    
    % 7. Bring outside points back to the boundary
    %   {ix} returns a logical array - 0 = false, 1 = true for the statement {d} > 0 where d is the distance of every point in {pos} to the boundary
    %   {dgrax} and {dgrady} evaluate {distFunction} for a point offset by {deps} from original points outside the boundary and return direction (positive or negative) that point must move
    %   use directional information from {dgradx} and {dgrady} to project points outside the boundary directly back onto it
    
    d = feval( distFunction, pos, varargin{:} ); ix = d > 0; % error might be here inside distFunction
    dgradx = ( feval( distFunction, [ pos( ix, 1 ) + deps, pos( ix, 2 ) ], varargin{:} ) - d( ix ) ) / deps;
    dgrady = ( feval( distFunction, [ pos( ix, 1 ), pos( ix, 2 ) + deps ], varargin{:} ) - d( ix ) ) / deps;
    pos( ix, : ) = pos( ix, : ) - [ d( ix ).*dgradx, d( ix ).*dgrady ];
    
    % 8. Termination criterion: All interior nodes move less than dptol (scaled)
    if max( sqrt( sum( deltat * Ftot( d < -geps, : ).^2, 2 ) ) / h0 ) < dptol, break; end
end
end