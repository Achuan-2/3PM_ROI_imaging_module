function mask_output = move_mask(binary_mask,down,right)
    arguments
        binary_mask 
        down = 0
        right = 0
    end
    % mask = zeros(512,512,3);
    empty_mask1 = zeros(size(binary_mask));
    empty_mask2 = zeros(size(binary_mask));
    if down >= 0 
        empty_mask1(down+1:end,:,:) = binary_mask(1:end-down,:,:);
    else
        empty_mask1(1:end+down,:,:) = binary_mask(-down+1:end,:,:);
    end

    if right >= 0
        empty_mask2(:,right+1:end,:) = empty_mask1(:,1:end-right,:);
    else
        empty_mask2(:,1:end+right,:) = empty_mask1(:,-right+1:end,:);
    end
    mask_output = empty_mask2;
end