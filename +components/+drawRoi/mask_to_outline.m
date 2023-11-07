function outline = mask_to_outline(mask)
    % mask_to_outline : convert roi mask to outline mask
    arguments (Input)
        mask (:,:) double
    end
    arguments (Output)
        outline (:,:) logical
    end
    B = bwboundaries(mask==1, 'holes'); % 获取不连通区域的边界

    % 初始化一个空矩阵来存储所有轮廓点
    numBoundaries = length(B);
    totalPoints = 0;
    for k = 1:numBoundaries
        totalPoints = totalPoints + size(B{k}, 1);
    end
    allBoundaries = zeros(totalPoints, 2);

    % 遍历每个不连通区域的边界
    currentIndex = 1;
    for k = 1:numBoundaries
        boundary = B{k};
        plot(boundary(:, 2), boundary(:, 1),'r', 'LineWidth', 2);
        % 将当前区域的轮廓点添加到allBoundaries矩阵中
        boundarySize = size(boundary, 1);
        allBoundaries(currentIndex:currentIndex+boundarySize-1, :) = boundary;
        currentIndex = currentIndex + boundarySize;
    end
    
    % 将轮廓坐标转换为outline mask
    outline = zeros(size(mask));
    linearIndices = sub2ind(size(outline),allBoundaries(:, 1), allBoundaries(:, 2));
    outline(linearIndices) = 1;
end