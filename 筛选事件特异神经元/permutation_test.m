function p_value = permutation_test(activity, event_start, event_end, num_permutations)
    observed_response = mean(activity(event_start:event_end));
    permuted_responses = zeros(1, num_permutations);
    
    for i = 1:num_permutations
        permuted_activity = activity(randperm(length(activity)));
        permuted_responses(i) = mean(permuted_activity(event_start:event_end));
    end
    
    p_value = sum(permuted_responses >= observed_response) / num_permutations;
end
