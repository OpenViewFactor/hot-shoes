% Procedurally generate GPHS bricks and 1/4 symmetric array of hot shoes

clear all
close all
clc

% --------------- SYSTEM PARAMETERS --------------- %

SHOE_SIZE = 0.9;              % [in]
VERT_SPACING = 0.145;         % [in]
HORIZ_SPACING = 0.1;          % [in]
CENTER_OFFSET = 3.01;         % [in]
DIAG_OFFSET = [0.507, 0.21];  % [in]
SHOE_STACK_COUNT = 18;

GPHS_WIDTH = 3.92;            % [in]
GPHS_DEPTH = 3.668;           % [in]
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

REFINE_SCALE = 20;

GENERATE_BRICKS = true;
GENERATE_SHOES = false;

EXPORT_TOGGLE = true;
GRAPH_TOGGLE = false;

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

    y_GPHS_mesh = rectGeneration(y_GPHS_bbox, y_GPHS_dir, REFINE_SCALE);

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