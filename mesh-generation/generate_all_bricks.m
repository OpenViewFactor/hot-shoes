function generate_all_bricks(refinement_range)
  parfor core=1:2
    if core == 1
      brick_type = 'step1';
    elseif core == 2
      brick_type = 'step2';
    end
    for i = 1 : length(refinement_range)
      generate_bricks(brick_type, ...
                      refinement_range(i), ...
                      true, ...
                      false);
    end
  end
end