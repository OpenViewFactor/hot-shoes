% TRANSLATEMESH move mesh by vector
%
% INPUTS:
% T: input triangulation
% v: Vector to move by
%
% OUTPUTS:
% T_n: output triangulation

function [T_n] = translateMesh(T, v)

    T_n = triangulation(T.ConnectivityList, T.Points + v);
    
end

