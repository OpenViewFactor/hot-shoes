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