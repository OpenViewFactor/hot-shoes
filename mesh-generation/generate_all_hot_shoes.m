function generate_all_hot_shoes(refinement_range)
  parfor i = 1 : length(refinement_range)
    generate_hot_shoes(refinement_range(i), ...
                       true, ...
                       false);
  end
end