function generate_hot_shoes(REFINE_SCALE, EXPORT_TOGGLE, GRAPH_TOGGLE)
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

  %* --------------- DUPLICATE HOT SHOES VERTICALLY --------------- *%
  SHOE_meshes = cell(SHOE_STACK_COUNT,4);
  SHOE_meshes{SHOE_STACK_COUNT, 1} = x_z_positive_y_face_mesh;
  SHOE_meshes{SHOE_STACK_COUNT, 2} = left_diagonal_face_mesh;
  SHOE_meshes{SHOE_STACK_COUNT, 3} = right_diagonal_face_mesh;
  SHOE_meshes{SHOE_STACK_COUNT, 4} = y_z_positive_x_face_mesh;

  for i = 1 : (SHOE_STACK_COUNT) - 1
    SHOE_meshes{SHOE_STACK_COUNT - i, 1} = translateMesh(x_z_positive_y_face_mesh, [0, 0, i*(SHOE_SIZE + VERT_SPACING)]);
    SHOE_meshes{SHOE_STACK_COUNT - i, 2} = translateMesh(left_diagonal_face_mesh, [0, 0, i*(SHOE_SIZE + VERT_SPACING)]);
    SHOE_meshes{SHOE_STACK_COUNT - i, 3} = translateMesh(right_diagonal_face_mesh, [0, 0, i*(SHOE_SIZE + VERT_SPACING)]);
    SHOE_meshes{SHOE_STACK_COUNT - i, 4} = translateMesh(y_z_positive_x_face_mesh, [0, 0, i*(SHOE_SIZE + VERT_SPACING)]);
  end

  %* --------------- EXPORT MESHES --------------- *%
  if EXPORT_TOGGLE
    if ~exist(['../assets/hot-shoes/ref-',num2str(REFINE_SCALE)], 'dir')
        mkdir(['../assets/hot-shoes/ref-',num2str(REFINE_SCALE)])
    end
    for i = 1 : SHOE_STACK_COUNT
        stlwrite(SHOE_meshes{i, 1}, ['../assets/hot-shoes/ref-',num2str(REFINE_SCALE),'/x_z_positive_y_face-row-',num2str(i),'-ref-',num2str(REFINE_SCALE),'.stl'], "binary")
        stlwrite(SHOE_meshes{i, 2}, ['../assets/hot-shoes/ref-',num2str(REFINE_SCALE),'/left_diagonal_face-row-',num2str(i),'-ref-',num2str(REFINE_SCALE),'.stl'], "binary")
        stlwrite(SHOE_meshes{i, 3}, ['../assets/hot-shoes/ref-',num2str(REFINE_SCALE),'/right_diagonal_face-row-',num2str(i),'-ref-',num2str(REFINE_SCALE),'.stl'], "binary")
        stlwrite(SHOE_meshes{i, 4}, ['../assets/hot-shoes/ref-',num2str(REFINE_SCALE),'/y_z_positive_x_face-row-',num2str(i),'-ref-',num2str(REFINE_SCALE),'.stl'], "binary")
    end
  end

  %* --------------- PLOT MESHES --------------- *%
  if GRAPH_TOGGLE
    
    % figure
    hold on
    for i = 1 : SHOE_STACK_COUNT
      trisurf(SHOE_meshes{i, 1},'EdgeColor','black','LineStyle','-','FaceColor','red')
      trisurf(SHOE_meshes{i, 2},'EdgeColor','black','LineStyle','-','FaceColor','red')
      trisurf(SHOE_meshes{i, 3},'EdgeColor','black','LineStyle','-','FaceColor','red')
      trisurf(SHOE_meshes{i, 4},'EdgeColor','black','LineStyle','-','FaceColor','red')
    end
    pbaspect([1,1,1])
    daspect([1,1,1])
    xlabel('x')
    ylabel('y')
    zlabel('z')
    view(3)

  end

end