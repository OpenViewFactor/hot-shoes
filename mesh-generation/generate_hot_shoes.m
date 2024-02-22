SHOE_SIZE = 0.9;              % [in]
VERT_SPACING = 0.145;         % [in]
HORIZ_SPACING = 0.1;          % [in]
CENTER_OFFSET = 3.01;         % [in]
DIAG_OFFSET = [0.507, 0.21];  % [in]
SHOE_STACK_COUNT = 18;

GENERATE_SHOES = true;
EXPORT_TOGGLE = false;
GRAPH_TOGGLE = true;

REFINE_SCALE = 20;

% --------------- GENERATE HOT SHOE FACES --------------- %

if GENERATE_SHOES

  x_SHOE_bbox = [HORIZ_SPACING/2, HORIZ_SPACING/2 + SHOE_SIZE;...
      CENTER_OFFSET, CENTER_OFFSET;...
      VERT_SPACING/2, VERT_SPACING/2 + SHOE_SIZE];

  x_SHOE_dir = [0, -1, 0];

  x_SHOE_mesh = rectGeneration(x_SHOE_bbox, x_SHOE_dir, REFINE_SCALE);

  x_SHOE_points = x_SHOE_mesh.Points;
  x_SHOE_pointers = x_SHOE_mesh.ConnectivityList;

  y_SHOE_mesh = flipMeshAboutPlane(x_SHOE_mesh, [0, 0, 0], [1, -1, 0]);

  diag_SHOE_bbox = [HORIZ_SPACING/2 + SHOE_SIZE + DIAG_OFFSET(1), HORIZ_SPACING/2 + SHOE_SIZE + DIAG_OFFSET(1) + SHOE_SIZE/sqrt(2);...
      CENTER_OFFSET - DIAG_OFFSET(2), CENTER_OFFSET - DIAG_OFFSET(2) - SHOE_SIZE/sqrt(2);...
      VERT_SPACING/2, VERT_SPACING/2 + SHOE_SIZE];

  diag_SHOE_dir = [-1/sqrt(2), -1/sqrt(2), 0];

  diag_SHOE_mesh = rectGeneration(diag_SHOE_bbox, diag_SHOE_dir, REFINE_SCALE);

  diag_SHOE_points = diag_SHOE_mesh.Points;
  diag_SHOE_pointers = diag_SHOE_mesh.ConnectivityList;

  mirr_diag_SHOE_mesh = translateMesh(diag_SHOE_mesh, [SHOE_SIZE + HORIZ_SPACING, -SHOE_SIZE - HORIZ_SPACING, 0]./sqrt(2));
  
  % <-> DUPLICATE HOT SHOES AROUND THE ARRAY <-> %
  
  SHOE_meshes = cell(SHOE_STACK_COUNT,4);
  SHOE_meshes{SHOE_STACK_COUNT, 1} = x_SHOE_mesh;
  SHOE_meshes{SHOE_STACK_COUNT, 2} = diag_SHOE_mesh;
  SHOE_meshes{SHOE_STACK_COUNT, 3} = mirr_diag_SHOE_mesh;
  SHOE_meshes{SHOE_STACK_COUNT, 4} = y_SHOE_mesh;

  for i = 1 : SHOE_STACK_COUNT - 1
      SHOE_meshes{SHOE_STACK_COUNT - i, 1} = translateMesh(x_SHOE_mesh, [0, 0, i*(SHOE_SIZE + VERT_SPACING)]);
      SHOE_meshes{SHOE_STACK_COUNT - i, 2} = translateMesh(diag_SHOE_mesh, [0, 0, i*(SHOE_SIZE + VERT_SPACING)]);
      SHOE_meshes{SHOE_STACK_COUNT - i, 3} = translateMesh(mirr_diag_SHOE_mesh, [0, 0, i*(SHOE_SIZE + VERT_SPACING)]);
      SHOE_meshes{SHOE_STACK_COUNT - i, 4} = translateMesh(y_SHOE_mesh, [0, 0, i*(SHOE_SIZE + VERT_SPACING)]);
  end
end


% <-> EXPORT MESHES <-> %

if EXPORT_TOGGLE
  if GENERATE_SHOES
      if ~exist(['../meshes/hot-shoes/ref-',num2str(REFINE_SCALE)], 'dir')
          mkdir(['../meshes/hot-shoes/ref-',num2str(REFINE_SCALE)])
      end
      for i = 1 : GPHS_STACK_COUNT
          stlwrite(SHOE_meshes{i, 1}, ['../meshes/hot-shoes/ref-',num2str(REFINE_SCALE),'/x-hot-shoe-row-',num2str(i),'-ref-',num2str(REFINE_SCALE),'.stl'], "binary")
          stlwrite(SHOE_meshes{i, 2}, ['../meshes/hot-shoes/ref-',num2str(REFINE_SCALE),'/diag-hot-shoe-row-',num2str(i),'-ref-',num2str(REFINE_SCALE),'.stl'], "binary")
          stlwrite(SHOE_meshes{i, 3}, ['../meshes/hot-shoes/ref-',num2str(REFINE_SCALE),'/mirr-diag-hot-shoe-row-',num2str(i),'-ref-',num2str(REFINE_SCALE),'.stl'], "binary")
          stlwrite(SHOE_meshes{i, 4}, ['../meshes/hot-shoes/ref-',num2str(REFINE_SCALE),'/y-hot-shoe-row-',num2str(i),'-ref-',num2str(REFINE_SCALE),'.stl'], "binary")
      end
  end
end

% <-> PLOT MESHES <-> %

if GRAPH_TOGGLE

  figure
  trisurf(GPHS_mesh,'EdgeColor','cyan','LineStyle',':','FaceColor','blue')
  hold on
  for i = 1 : GPHS_STACK_COUNT
      trisurf(SHOE_meshes{i, 1},'EdgeColor','white','LineStyle',':','FaceColor','red')
      trisurf(SHOE_meshes{i, 2},'EdgeColor','white','LineStyle',':','FaceColor','red')
      trisurf(SHOE_meshes{i, 3},'EdgeColor','white','LineStyle',':','FaceColor','red')
      trisurf(SHOE_meshes{i, 4},'EdgeColor','white','LineStyle',':','FaceColor','red')
  end
  pbaspect([1,1,1])
  daspect([1,1,1])
  xlabel('x')
  ylabel('y')
  zlabel('z')
  set(gca, 'xDir', 'reverse')
  set(gca, 'YDir', 'reverse')
end