function generate_hot_shoes_as_one_mesh(REFINE_SCALE, EXPORT_TOGGLE, GRAPH_TOGGLE)
  arguments
    REFINE_SCALE int8 {mustBePositive, mustBeInteger} = 2
    EXPORT_TOGGLE logical {mustBeNumericOrLogical} = false
    GRAPH_TOGGLE logical {mustBeNumericOrLogical} = true
  end

  %* --------------- SHOE PARAMETERS --------------- *%
  SHOE_SIZE = 0.9;              % [in]
  VERT_SPACING = 0.145;         % [in]
  HORIZ_SPACING = 0.1;          % [in]
  CENTER_OFFSET = 3.01;         % [in]
  DIAG_OFFSET = [0.507, 0.21];  % [in]
  SHOE_STACK_COUNT = 18;

  %* --------------- GENERATE HOT SHOES --------------- *%
  %! generate hot shoe face parallel to the x-z plane
  planar_corner = [HORIZ_SPACING / 2, CENTER_OFFSET, VERT_SPACING / 2];
  x_z_positive_y_face_vertices = [planar_corner; ...
                                  planar_corner(1) + SHOE_SIZE, planar_corner(2), planar_corner(3); ...
                                  planar_corner(1) + SHOE_SIZE, planar_corner(2), planar_corner(3) + SHOE_SIZE; ...
                                  planar_corner(1), planar_corner(2), planar_corner(3) + SHOE_SIZE];
  x_z_positive_y_face_mesh = generate_rectangle(x_z_positive_y_face_vertices, REFINE_SCALE);
  %! generate hot shoe face parallel to the y-z plane
  y_z_positive_x_face_mesh = flipMeshAboutPlane(x_z_positive_y_face_mesh, [1,1,1], [-1,1,0]);
  
  %! generate hot shoe faces along the diagonal between the above two meshes
  diagonal_corner = [HORIZ_SPACING / 2 + SHOE_SIZE + DIAG_OFFSET(1), CENTER_OFFSET - DIAG_OFFSET(2), VERT_SPACING / 2];
  left_diagonal_face_vertices = [diagonal_corner; ...
                                 diagonal_corner(1) + SHOE_SIZE * 1/sqrt(2), diagonal_corner(2) - SHOE_SIZE * 1/sqrt(2), diagonal_corner(3); ...
                                 diagonal_corner(1) + SHOE_SIZE * 1/sqrt(2), diagonal_corner(2) - SHOE_SIZE * 1/sqrt(2), diagonal_corner(3) + SHOE_SIZE;...
                                 diagonal_corner(1), diagonal_corner(2), diagonal_corner(3) + SHOE_SIZE];
  left_diagonal_face_mesh = generate_rectangle(left_diagonal_face_vertices, REFINE_SCALE);
  right_diagonal_face_mesh = translateMesh(left_diagonal_face_mesh, (SHOE_SIZE + HORIZ_SPACING) * [1/sqrt(2), -1/sqrt(2), 0]);


  %* --------------- PACKAGE THE MESHES --------------- *%
  all_shoes_in_row_mesh_points = [x_z_positive_y_face_mesh.Points;...
                                  left_diagonal_face_mesh.Points;...
                                  y_z_positive_x_face_mesh.Points;...
                                  right_diagonal_face_mesh.Points];
  all_shoes_in_row_mesh_connectivity = [x_z_positive_y_face_mesh.ConnectivityList;...
                                        left_diagonal_face_mesh.ConnectivityList + (size(x_z_positive_y_face_mesh.Points, 1));...
                                        y_z_positive_x_face_mesh.ConnectivityList + (size(x_z_positive_y_face_mesh.Points, 1) +...
                                                                                     size(left_diagonal_face_mesh.Points, 1));...
                                        right_diagonal_face_mesh.ConnectivityList + (size(x_z_positive_y_face_mesh.Points, 1) +...
                                                                                    size(left_diagonal_face_mesh.Points, 1) +...
                                                                                    size(y_z_positive_x_face_mesh.Points, 1))];

  %* --------------- FILTER FOR UNIQUE POINTS --------------- *%
  [all_shoes_in_row_mesh_points, ~, IC] = unique(all_shoes_in_row_mesh_points, 'rows', 'stable');
  all_shoes_in_row_mesh_connectivity = IC(all_shoes_in_row_mesh_connectivity);
  %* --------------- STORE THE TRIANGULATION --------------- *%
  all_shoes_in_row_mesh = triangulation(all_shoes_in_row_mesh_connectivity, all_shoes_in_row_mesh_points);


  %* --------------- DUPLICATE EACH ROW VERTICALLY --------------- *%
  SHOE_meshes = cell(SHOE_STACK_COUNT,1);
  SHOE_meshes{SHOE_STACK_COUNT, 1} = all_shoes_in_row_mesh;

  for i = 1 : (SHOE_STACK_COUNT) - 1
    SHOE_meshes{SHOE_STACK_COUNT - i, 1} = translateMesh(all_shoes_in_row_mesh, [0, 0, i*(SHOE_SIZE + VERT_SPACING)]);
  end

  all_points = [];
  all_connectivity = [];
  
  for i = 1 : SHOE_STACK_COUNT
    all_connectivity = [all_connectivity; SHOE_meshes{i}.ConnectivityList + size(all_points,1)];
    all_points = [all_points; SHOE_meshes{i}.Points];
  end
  all_shoes_triangulation = triangulation(all_connectivity, all_points);

  %* --------------- EXPORT MESHES --------------- *%
  if EXPORT_TOGGLE
    if ~exist(['../assets/hot-shoes/ref-',num2str(REFINE_SCALE)], 'dir')
        mkdir(['../assets/hot-shoes/ref-',num2str(REFINE_SCALE)])
    end
      stlwrite(all_shoes_triangulation, ['../assets/hot-shoes/ref-',num2str(REFINE_SCALE),'/all_shoes','-ref-',num2str(REFINE_SCALE),'.stl'], "binary")
  end

  %* --------------- PLOT MESHES --------------- *%
  if GRAPH_TOGGLE
    
    % figure
    hold on
    for i = 1 : SHOE_STACK_COUNT
      trisurf(all_shoes_triangulation,'EdgeColor','black','LineStyle','-','FaceColor','red')
    end
    pbaspect([1,1,1])
    daspect([1,1,1])
    xlabel('x')
    ylabel('y')
    zlabel('z')
    view(3)

  end

end