function generate_individual_bricks(REFINE_SCALE, EXPORT_TOGGLE, GRAPH_TOGGLE, STEP_TYPE)
  arguments
    REFINE_SCALE int8 {mustBePositive, mustBeInteger} = 2
    EXPORT_TOGGLE logical {mustBeNumericOrLogical} = false
    GRAPH_TOGGLE logical {mustBeNumericOrLogical} = true
    STEP_TYPE string {mustBeText} = 'STEP1'
  end

  %* --------------- BRICK PARAMETERS --------------- *%
  GPHS_WIDTH_x = 3.92;            % [in]
  GPHS_DEPTH_y = 3.668;           % [in]
  %! ----- set brick type settings ----- !%
  if strcmpi(STEP_TYPE, 'step1')
    GPHS_HEIGHT_z = 2.09;         % [in]
    GPHS_STACK_COUNT = 18;
    STEP1 = true; STEP2 = false;
  elseif strcmpi(STEP_TYPE, 'step2')
    GPHS_HEIGHT_z = 2.29;         % [in]
    GPHS_STACK_COUNT = 16;
    STEP1 = false; STEP2 = true;
  end


  %* --------------- GENERATE BRICK FACES --------------- *%
  %! generate GPHS brick faces parallel to the x-z plane centered at (0,0,0)
  x_z_positive_y_face_vertices = [-GPHS_WIDTH_x/2, GPHS_DEPTH_y/2,  -GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2);...
                                   GPHS_WIDTH_x/2, GPHS_DEPTH_y/2,  -GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2);...
                                   GPHS_WIDTH_x/2, GPHS_DEPTH_y/2,  -GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2 - 1);...
                                  -GPHS_WIDTH_x/2, GPHS_DEPTH_y/2,  -GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2 - 1)];
  x_z_positive_y_face_mesh = generate_rectangle(x_z_positive_y_face_vertices, REFINE_SCALE);
  x_z_positive_y_face_mesh = flipNormals(x_z_positive_y_face_mesh);
  x_z_negative_y_face_mesh = flipNormals(translateMesh(x_z_positive_y_face_mesh,[0,-GPHS_DEPTH_y,0]));

  %! generate bricks faces parallel to the y-z plane centered at (0,0,0)
  y_z_positive_x_face_vertices = [GPHS_WIDTH_x/2,  GPHS_DEPTH_y/2,  -GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2);...
                                  GPHS_WIDTH_x/2, -GPHS_DEPTH_y/2,  -GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2);...
                                  GPHS_WIDTH_x/2, -GPHS_DEPTH_y/2,  -GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2 - 1);...
                                  GPHS_WIDTH_x/2,  GPHS_DEPTH_y/2,  -GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2 - 1)];
  y_z_positive_x_face_mesh = generate_rectangle(y_z_positive_x_face_vertices, REFINE_SCALE);
  y_z_positive_x_face_mesh = flipNormals(y_z_positive_x_face_mesh);
  y_z_negative_x_face_mesh = flipNormals(translateMesh(y_z_positive_x_face_mesh,[-GPHS_WIDTH_x,0,0]));

  %* --------------- PACKAGE THE MESHES --------------- *%
  GPHS_bricks_mesh_points = [x_z_positive_y_face_mesh.Points;...
                             x_z_negative_y_face_mesh.Points;...
                             y_z_positive_x_face_mesh.Points;...
                             y_z_negative_x_face_mesh.Points];
  GPHS_bricks_mesh_connectivity = [x_z_positive_y_face_mesh.ConnectivityList;...
                                   x_z_negative_y_face_mesh.ConnectivityList + (size(x_z_positive_y_face_mesh.Points, 1));...
                                   y_z_positive_x_face_mesh.ConnectivityList + (size(x_z_positive_y_face_mesh.Points, 1) +...
                                                                                size(x_z_negative_y_face_mesh.Points, 1));...
                                   y_z_negative_x_face_mesh.ConnectivityList + (size(x_z_positive_y_face_mesh.Points, 1) +...
                                                                                size(x_z_negative_y_face_mesh.Points, 1) +...
                                                                                size(y_z_positive_x_face_mesh.Points, 1))];

  %* --------------- FILTER FOR UNIQUE POINTS --------------- *%
  [GPHS_bricks_mesh_points, ~, IC] = unique(GPHS_bricks_mesh_points, 'rows', 'stable');
  GPHS_bricks_mesh_connectivity = IC(GPHS_bricks_mesh_connectivity);
  %* --------------- STORE THE TRIANGULATION --------------- *%
  GPHS_bricks_mesh = triangulation(GPHS_bricks_mesh_connectivity, GPHS_bricks_mesh_points);

  %* --------------- DUPLICATE BRICKS VERTICALLY --------------- *%
  BRICK_meshes = cell(GPHS_STACK_COUNT,1);
  BRICK_meshes{GPHS_STACK_COUNT, 1} = GPHS_bricks_mesh;

  for i = 1 : (GPHS_STACK_COUNT) - 1
    BRICK_meshes{GPHS_STACK_COUNT - i, 1} = translateMesh(GPHS_bricks_mesh, [0, 0, i*(GPHS_HEIGHT_z)]);
  end

  %* --------------- EXPORT MESHES --------------- *%
  if EXPORT_TOGGLE
    if ~exist(['../assets/bricks_individual/ref-',num2str(REFINE_SCALE)], 'dir')
        mkdir(['../assets/bricks_individual/ref-',num2str(REFINE_SCALE)])
    end
    for i = 1 : GPHS_STACK_COUNT
        stlwrite(BRICK_meshes{i, 1}, ['../assets/bricks_individual/ref-',num2str(REFINE_SCALE),'/GPHS_brick-row-',num2str(i),'-ref-',num2str(REFINE_SCALE),'.stl'], "binary")
    end
  end

  %* --------------- PLOT MESHES --------------- *%
  if GRAPH_TOGGLE
    
    % figure
    hold on
    for i = 1 : GPHS_STACK_COUNT
      trisurf(BRICK_meshes{i, 1},'EdgeColor',[1,1,1].*mod(i,2),'LineStyle','-','FaceColor',[1,0,0].*i/GPHS_STACK_COUNT)
    end
    pbaspect([1,1,1])
    daspect([1,1,1])
    xlabel('x')
    ylabel('y')
    zlabel('z')
    view(3)

  end

end