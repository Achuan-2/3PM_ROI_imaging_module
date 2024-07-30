function refImg = pick_initial_reference(frames)
    % Computes the initial reference image from a set of frames
    % The input frames should be in the format Ly x Lx x nFrames
    
    % Get the dimensions of the input frames
    [Ly, Lx, nFrames] = size(frames);
    
    % Reshape and zero-center the frames
    reshapedFrames = single(reshape(frames, [], nFrames)');
    reshapedFrames = reshapedFrames - mean(reshapedFrames, 2);
    
    % Compute the normalized cross-correlation matrix
    ccMatrix = reshapedFrames * reshapedFrames';
    normCCMatrix = ccMatrix ./ (sqrt(diag(ccMatrix)) * sqrt(diag(ccMatrix))');
    
    % Find the frame with the highest average correlation
    numMatches = 19;
    CCsort = sort(normCCMatrix, 2, 'descend');
    bestCC = mean(CCsort(:, 2:(numMatches+1)), 2);
    [~, bestFrameIdx] = max(bestCC);
    
    % Select the top correlated frames
    [~, indsort] = sort(normCCMatrix(bestFrameIdx, :), 'descend');
    selectedFrameIndices = indsort(1:(numMatches+1));
    
    % Compute the reference image as the mean of the selected frames
    refImg = mean(reshapedFrames(selectedFrameIndices, :), 1);
    refImg = reshape(refImg, Ly, Lx);
end
