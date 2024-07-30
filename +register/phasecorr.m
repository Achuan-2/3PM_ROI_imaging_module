function [ymax, xmax, cmax] = phasecorr(data, cfRefImg, maxregshift, smoothSigmaTime)
    % Compute phase correlation between data and reference image

    % Parameters
    % ----------
    % data : int16
    %     array that's frames x Ly x Lx
    % maxregshift : float
    %     maximum shift as a fraction of the minimum dimension of data (min(Ly,Lx) * maxregshift)
    % smoothSigmaTime : float
    %     how many frames to smooth in time

    % Returns
    % -------
    % ymax : int
    %     shifts in y from cfRefImg to data for each frame
    % xmax : int
    %     shifts in x from cfRefImg to data for each frame
    % cmax : float
    %     maximum of phase correlation for each frame

    minDim = min(size(data, 1), size(data, 2));  % maximum registration shift allowed
    lcorr = min(round(maxregshift * minDim), floor(minDim / 2));

    % Convolve data with cfRefImg
    data = register.convolve(data, cfRefImg);
    cc = real([
        data( end-lcorr+1:end, end-lcorr+1:end,:), data(end-lcorr+1:end, 1:lcorr+1,:);
        data(1:lcorr+1, end-lcorr+1:end,:), data( 1:lcorr+1, 1:lcorr+1,:)
    ]);

    if smoothSigmaTime > 0
        cc = register.temporal_smooth(cc, smoothSigmaTime);
    end

    nFrames = size(data, 3);
    ymax = zeros(nFrames, 1, 'int32');
    xmax = zeros(nFrames, 1, 'int32');
    cmax = zeros(nFrames, 1,'single');
    for t = 1:nFrames
        [max_val, max_idx] = max(cc(:, :, t), [], 'all', 'linear');
        [ymax(t), xmax(t)] = ind2sub([2*lcorr+1, 2*lcorr+1], max_idx);
        cmax(t) = max_val;
    end

    cmax = cc(sub2ind(size(cc),  ymax, xmax,(1:nFrames)'));
    ymax = ymax - lcorr;
    xmax = xmax - lcorr;
end