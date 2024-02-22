clear all
close all
clc

GPHS_HEIGHT = 2.09;           % [in]

if GPHS_HEIGHT == 2.09
  STEP1 = true;
  STEP2 = false;
  GPHS_STACK_COUNT = 18;
elseif GPHS_HEIGHT == 2.29
  STEP1 = false;
  STEP2 = true;
  GPHS_STACK_COUNT = 16;
end

GENERATE_BRICKS = true;
EXPORT_TOGGLE = false;
GRAPH_TOGGLE = true;

REFINE_SCALE = 20;

% --------------- GENERATE BRICK FACES --------------- %

if GENERATE_BRICKS

  x_GPHS_bbox = [-GPHS_WIDTH/2, GPHS_WIDTH/2;...
      GPHS_DEPTH/2, GPHS_DEPTH/2;...
      0, GPHS_HEIGHT];

  x_GPHS_dir = [0, 1, 0];

  x_GPHS_mesh = rectGeneration(x_GPHS_bbox, x_GPHS_dir, REFINE_SCALE);

  x_GPHS_points = x_GPHS_mesh.Points;
  x_GPHS_pointers = x_GPHS_mesh.ConnectivityList;

  y_GPHS_bbox = [GPHS_WIDTH/2, GPHS_WIDTH/2;...
      -GPHS_DEPTH/2, GPHS_DEPTH/2;...
      0, GPHS_HEIGHT];

  y_GPHS_dir = [1, 0, 0];

  y_GPHS_mesh = generate_rectangle(y_GPHS_bbox, y_GPHS_dir, REFINE_SCALE);

  y_GPHS_points = y_GPHS_mesh.Points;
  y_GPHS_pointers = y_GPHS_mesh.ConnectivityList;


  GPHS_points = [x_GPHS_points; y_GPHS_points];
  GPHS_pointers = [x_GPHS_pointers; y_GPHS_pointers + size(x_GPHS_points, 1)];

  GPHS_mesh = triangulation(GPHS_pointers, GPHS_points);

  % <-> DUPLICATE BRICKS VERTICALLY <-> %
  
  GPHS_meshes = cell(GPHS_STACK_COUNT,1);
  GPHS_meshes{GPHS_STACK_COUNT/2} = GPHS_mesh;

  for i = 1:GPHS_STACK_COUNT/2
      GPHS_meshes{GPHS_STACK_COUNT/2+i} = translateMesh(GPHS_mesh, [0, 0, -i*GPHS_HEIGHT]);
      if i == GPHS_STACK_COUNT/2
          break;
      end
      GPHS_meshes{GPHS_STACK_COUNT/2-i} = translateMesh(GPHS_mesh, [0, 0, i*GPHS_HEIGHT]);
  end
  
  % <-> PACKAGE DUPLICATES INTO ONE MESH <-> %

  GPHS_points = zeros(1, 3);
  GPHS_pointers = zeros(1, 3);

  for i = 1 : GPHS_STACK_COUNT
      prev_points_size = size(GPHS_points,1);
      GPHS_points = [GPHS_points; GPHS_meshes{i}.Points];
      GPHS_pointers = [GPHS_pointers; GPHS_meshes{i}.ConnectivityList + prev_points_size];
  end

  GPHS_points(1,:) = [];
  GPHS_pointers(1,:) = [];
  GPHS_pointers = GPHS_pointers - 1;

  GPHS_mesh = triangulation(GPHS_pointers, GPHS_points);

end

% <-> EXPORT MESHES <-> %

if EXPORT_TOGGLE
  if GENERATE_BRICKS && STEP1
      if ~exist(['../meshes/step1-GPHS-bricks-ref-',num2str(REFINE_SCALE)], 'dir')
          mkdir(['../meshes/step1-GPHS-bricks-ref-',num2str(REFINE_SCALE)])
      end
      stlwrite(GPHS_mesh, ['../meshes/step1-GPHS-bricks-ref-',num2str(REFINE_SCALE),'/step1-GPHS-bricks-stack-ref-',num2str(REFINE_SCALE),'.stl'], "binary");
  elseif GENERATE_BRICKS && STEP2
      if ~exist(['../meshes/step2-GPHS-bricks-ref-',num2str(REFINE_SCALE)], 'dir')
          mkdir(['../meshes/step2-GPHS-bricks-ref-',num2str(REFINE_SCALE)])
      end
      stlwrite(GPHS_mesh, ['../meshes/step2-GPHS-bricks-ref-',num2str(REFINE_SCALE),'/step2-GPHS-bricks-stack-ref-',num2str(REFINE_SCALE),'.stl'], "binary");
  end
end

% <-> PLOT MESHES <-> %

if GRAPH_TOGGLE

  figure
  trisurf(GPHS_mesh,'EdgeColor','cyan','LineStyle',':','FaceColor','blue')
  pbaspect([1,1,1])
  daspect([1,1,1])
  xlabel('x')
  ylabel('y')
  zlabel('z')
  set(gca, 'xDir', 'reverse')
  set(gca, 'YDir', 'reverse')
end