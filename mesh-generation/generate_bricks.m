function generate_bricks(STEP_TYPE, REFINE_SCALE, EXPORT_TOGGLE, GRAPH_TOGGLE)
  arguments
    STEP_TYPE string {mustBeText} = 'STEP1'
    REFINE_SCALE int8 {mustBePositive, mustBeInteger} = 1
    EXPORT_TOGGLE logical {mustBeNumericOrLogical} = false
    GRAPH_TOGGLE logical {mustBeNumericOrLogical} = true
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
                                   GPHS_WIDTH_x/2, GPHS_DEPTH_y/2,   GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2);...
                                  -GPHS_WIDTH_x/2, GPHS_DEPTH_y/2,   GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2)];
  x_z_positive_y_face_mesh = generate_rectangle(x_z_positive_y_face_vertices, REFINE_SCALE);
  x_z_positive_y_face_mesh = flipNormals(x_z_positive_y_face_mesh);
  x_z_negative_y_face_mesh = flipNormals(translateMesh(x_z_positive_y_face_mesh,[0,-GPHS_DEPTH_y,0]));

  %! generate bricks faces parallel to the y-z plane centered at (0,0,0)
  y_z_positive_x_face_vertices = [GPHS_WIDTH_x/2,  GPHS_DEPTH_y/2,  -GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2);...
                                  GPHS_WIDTH_x/2, -GPHS_DEPTH_y/2,  -GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2);...
                                  GPHS_WIDTH_x/2, -GPHS_DEPTH_y/2,   GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2);...
                                  GPHS_WIDTH_x/2,  GPHS_DEPTH_y/2,   GPHS_HEIGHT_z*(GPHS_STACK_COUNT/2)];
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

  %? <-><-><-><-><-> EXPORT STL MESHES <-><-><-><-><-> ?%
  if EXPORT_TOGGLE
    if STEP1
        if ~exist(['../assets/bricks/step1-GPHS-bricks-ref-',num2str(REFINE_SCALE)], 'dir')
            mkdir(['../assets/bricks/step1-GPHS-bricks-ref-',num2str(REFINE_SCALE)])
        end
        stlwrite(GPHS_bricks_mesh, ['../assets/bricks/step1-GPHS-bricks-ref-',num2str(REFINE_SCALE),'/step1-GPHS-bricks-stack-ref-',num2str(REFINE_SCALE),'.stl'], "binary");
    elseif STEP2
        if ~exist(['../assets/bricks/step2-GPHS-bricks-ref-',num2str(REFINE_SCALE)], 'dir')
            mkdir(['../assets/bricks/step2-GPHS-bricks-ref-',num2str(REFINE_SCALE)])
        end
        stlwrite(GPHS_bricks_mesh, ['../assets/bricks/step2-GPHS-bricks-ref-',num2str(REFINE_SCALE),'/step2-GPHS-bricks-stack-ref-',num2str(REFINE_SCALE),'.stl'], "binary");
    end
  end

  %? <-><-><-><-><-> PLOT STL MESHES <-><-><-><-><-> ?%
  if GRAPH_TOGGLE
    
    trisurf(GPHS_bricks_mesh,'EdgeColor','black','LineStyle','-','FaceColor','blue')
    pbaspect([1,1,1])
    daspect([1,1,1])
    xlabel('x')
    ylabel('y')
    zlabel('z')

  end

end