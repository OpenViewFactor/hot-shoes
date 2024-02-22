function [T_n] = flipNormals(T)
%FLIPNORMALS flip all triangle normals in mesh
%
% INPUTS:
% T: input triangulation
%
% OUTPUTS:
% T_n: output triangulation

    nc = [T.ConnectivityList(:,1) T.ConnectivityList(:,3) T.ConnectivityList(:,2)];
    T_n = triangulation(nc, T.Points);
    
end

