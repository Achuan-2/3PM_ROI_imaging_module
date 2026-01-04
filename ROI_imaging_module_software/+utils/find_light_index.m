function lightIndex= find_light_index(imgStack)
    % read the first 10 frames
    frames = imgStack(:,:,1:10);

    % caculate the sum of each frame
    pixelSums = zeros(1,10);
    for i = 1:10
        pixelSums(i) = sum(frames(:,:,i),"all");
    end

    % find the lightest frame
    [~,lightIndex] = max(pixelSums);

end