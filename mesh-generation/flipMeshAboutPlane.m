function [T_n] = flipMeshAboutPlane(T, plane_p, plane_n)
%FLIPMESHABOUTPLANE flip mesh about a plane
%
% INPUTS:
% T: input triangulation
% plane_p: point on flip plane
% plane_n: normal of flip plane
%
% OUTPUTS:
% T_n: output triangulation

    % Ensure normalized
    plane_n = plane_n ./ norm(plane_n);

    % Get general form of plane (Ax + By + Cz = D)
    % [A, B, C] = plane_n;
    D = dot(plane_p, plane_n);

    % Get distance of each point to plane
    distances = (dot(repmat(plane_n,size(T.Points,1),1),T.Points,2) + D)./norm(plane_n);

    % Get translation vectors for each point
    translations = 2 .* distances .* plane_n;

    % Flip normals
    nc = [T.ConnectivityList(:,1) T.ConnectivityList(:,3) T.ConnectivityList(:,2)];

    % Apply translations
    T_n = triangulation(nc, T.Points - translations);
    
end

