%% distmesh - from Per-Olf Persson and Gilbert Strang
% NOTE: some variables have been renamed from the original for more clarity

% Function Parameters:
%   [] distFunction : geometry is given as a distance function - returns the signed distance from each node location p to the closest boundary
%   [] hFun : (relative) desired edge length function {hFun} = h(x,y) - could be a scalar but could also be some function of x, y
%   [] h0 : gives the distance between points initialized in the first distribution (see step 1)
%   [] bbox : bounding box for the region is an array {bbox} = [xmin, ymin; xmax, ymax]
%   [] pFix : positions of the fixed nodes are given as an array {pFix} (subset of {pos}) any additional parameters to the functions {distFunction} and {hFun} can be specified in varargin

% Function Output:
%   [] pos : node positions in an Nx2 array with x-y coordinates of each node
%   [] triangulation : triangle connections list, similar to the ConnectiviyList in a triangulation structure

function [pos, triangulation] = distmesh2d(distFunction, hFun, h0, bbox, pFix, varargin)

    dptol = 0.001;
    ttol = 0.01;
    Fscale = 1.1;
    deltat = 0.1;
    geps = 0.001 * h0;
    deps = sqrt(eps) * h0;
    
    [x, y] = meshgrid( bbox(1, 1):h0:bbox(2, 1) , bbox(1, 2):h0*sqrt(3)/2:bbox(2, 2) );
    x( 2:2:end, : ) = x( 2:2:end, : ) + h0/2;
    pos = [ x(:) , y(:) ];
    pos = pos( feval( distFunction, pos, varargin{:} ) < geps, : );
    r0 = 1./feval( hFun, pos, varargin{:} ).^2;
    pos = [ pFix; pos( rand( size( pos, 1 ), 1 ) < r0./max(r0), : ) ];
    pos = unique(pos, 'rows', 'stable');
    N = size( pos, 1 );
    
    oldPos = inf;
    while 1
        
        if max( sqrt( sum( ( pos - oldPos ).^2, 2 ) ) / h0 ) > ttol
  
            pos = unique(pos, 'rows', 'stable');
            oldPos = pos;
            triangulation = delaunayn( pos );
            pCents = ( pos( triangulation( :, 1 ), : ) + pos( triangulation( :, 2 ), : ) + pos( triangulation( :, 3 ), : )) / 3;
            triangulation = triangulation( feval( distFunction, pCents, varargin{:} ) < -geps, : );
            
            bars = [ triangulation( :, [ 1, 2 ] ); triangulation( :, [ 1, 3 ] ); triangulation( :, [ 2, 3 ] ) ];
            bars = unique( sort( bars, 2 ), 'rows');
            
            
        end
        % 5. Graphical output of the current mesh (SLOWS ALGORITHM DOWN SIGNIFICANTLY)
    %     figure
    %     trimesh( triangulation, pos( :, 1 ), pos( :, 2 ), zeros( (length(pos(:,1))) , 1 ) )
    %     view(3)
    %     axis equal
    %     drawnow
        
        barVec = pos( bars( :, 1 ), : ) - pos( bars( :, 2 ), : );
        barLengths = sqrt( sum( barVec.^2, 2) );
        hbars = feval( hFun, ( pos(bars( :, 1 ), : ) + pos( bars( :, 2 ), : ) ) / 2, varargin{:} );
        L0 = hbars * Fscale * sqrt( sum( barLengths.^2 ) / sum( hbars.^2 ) );
        F = max( L0 - barLengths, 0 );
        Fvec = F./barLengths * [ 1, 1 ].*barVec;
        Ftot = full( sparse( bars( :, [ 1, 1, 2, 2 ] ), ones( size( F ) ) * [ 1, 2, 1, 2 ], [ Fvec, -Fvec ], N , 2 ) );
        Ftot( 1:size( pFix, 1 ), : ) = 0;
        pos = pos + deltat * Ftot;
        
        d = feval( distFunction, pos, varargin{:} ); ix = d > 0;
        dgradx = ( feval( distFunction, [ pos( ix, 1 ) + deps, pos( ix, 2 ) ], varargin{:} ) - d( ix ) ) / deps;
        dgrady = ( feval( distFunction, [ pos( ix, 1 ), pos( ix, 2 ) + deps ], varargin{:} ) - d( ix ) ) / deps;
        pos( ix, : ) = pos( ix, : ) - [ d( ix ).*dgradx, d( ix ).*dgrady ];
        
        if max( sqrt( sum( deltat * Ftot( d < -geps, : ).^2, 2 ) ) / h0 ) < dptol, break; end
    end
    end