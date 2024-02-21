function [T_n] = translateMesh(T, v)
%TRANSLATEMESH move mesh by vector
%
% INPUTS:
% T: input triangulation
% v: Vector to move by
%
% OUTPUTS:
% T_n: output triangulation

    T_n = triangulation(T.ConnectivityList, T.Points + v);
    
end

