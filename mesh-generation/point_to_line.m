% ----- Point to Line ----- %

% Function Description:
%   point_to_line.m returns the distance from a point p or set of points to a line segment
%   defined by two vertices, v1 and v2

% Function Parameters:
%   [] p : a single point or set of points to consider
%   [] v1 : start vertex of the line segment
%   [] v2 : end vertex of the line segment

% Function Output:
%   [] d : distance between the point/points and the line segment

function d = point_to_line(p, v1, v2)

  angle = @(a, b) acosd(dot(ones(size(a,1),3) .* b, a, 2) ./ (sqrt(dot(a, a, 2)) .* norm(b)));
  magnitude = @(a) sqrt(sum(a.^2, 2));
  v_size = @(a, b) ones(size(b,1),3) .* a;  % replicates vector a to match the size of b
  distance = @(a, b) a - (dot(a, v_size(b./norm(b), a), 2) .* b./norm(b)); % distance a -> b
  
  e1 = p - v1;  % edge from points p to vertex v1
  e2 = p - v2;  % edge from points p to vertex v2
  l = v2 - v1;  % line segment v1 -> v2

  t1 = angle(e1, l);   % angle between (v1 -> p) and the line segment itself
  t2 = angle(e2, -l);  % angle between (v2 -> p) and the line segment itself
  
  case1 = t1 > 90;                            % booleans
  case2 = t2 > 90;                            % booleans
  case3 = all([~(t1 > 90), ~(t2 > 90)], 2);   % booleans

  d = zeros(size(p,1), 1);    % initialize distance vector for each point
  d(case1) = magnitude(e1(case1, :));    % evaluate case 1
  d(case2) = magnitude(e2(case2, :));    % evaluate case 2
  d(case3) = magnitude(distance(e1(case3, :), l));  % evaluate case 3

end