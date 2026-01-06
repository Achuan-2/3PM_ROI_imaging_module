classdef RIMAClass
    %% USAGE:
    % [reg_frames, refImg, offsets, corr_values] = RIMA.RIMAClass.register(roi_frames,'refImg', full_frames);

    methods (Static)
        function [reg_frames, refImg, offsets, corr_values] = register(frames, options)
            arguments
                frames (:,:,:) {mustBeNumeric}
                options.refImg = []
                options.compute_ref (1,1) logical = true
                options.niter (1,1) {mustBePositive, mustBeInteger} = 8
                options.max_shift (1,1) {mustBeNonnegative} = 0.1
                options.smooth_sigma (1,1) {mustBeNonnegative} = 1.125
            end
            
            [Ly, Lx, nframes] = size(frames);
            
            % Compute or use the provided reference image
            if ~isempty(options.refImg)
                refImg = options.refImg;
            elseif options.compute_ref
                ref_options = struct();
                ref_options.niter = options.niter;
                ref_options.max_shift = options.max_shift;
                ref_options.smooth_sigma = options.smooth_sigma;
                refImg = RIMA.RIMAClass.compute_reference(frames, ref_options);
            else
                refImg = frames(:, :, 1);
            end
            
            % Initialize outputs
            reg_frames = zeros(size(frames), class(frames));
            offsets = zeros(nframes, 2);
            corr_values = zeros(nframes, 1);
            
            fprintf('Registration progress: ');
            for i = 1:nframes
                if mod(i, 100) == 1 || i == nframes
                    fprintf('Processing %d/%d\n ', i, nframes);
                end
                
                [offset, peak, ~] = RIMA.RIMAClass.grad_corr(refImg, frames(:,:,i),  ...
                    options.max_shift, options.smooth_sigma);
                
                reg_frames(:, :, i) = RIMA.RIMAClass.shift_frame(frames(:, :, i), ...
                    offset(2), offset(1));
                
                offsets(i, :) = offset;
                corr_values(i) = peak;
            end
            fprintf('\n');
        end
    end
    
    methods (Static, Access = private)
        function refImg = compute_reference(frames, options)
            if nargin < 2
                options = struct();
            end
            if ~isfield(options, 'niter'), options.niter = 8; end
            if ~isfield(options, 'max_shift'), options.max_shift = 0.1; end
            if ~isfield(options, 'smooth_sigma'), options.smooth_sigma = 1.125; end
            if ~isfield(options, 'mask'), options.mask = []; end
            if ~isfield(options, 'init_frames'), options.init_frames = 300; end
            
            useMask = ~isempty(options.mask);
            if useMask
                mask = logical(options.mask);
            else
                mask = [];
            end
            preprocess = @(img) RIMA.RIMAClass.preprocessFrame(img, mask, useMask);
            nframes = size(frames, 3);
            init_n = min(options.init_frames, nframes);
            refImg = RIMA.RIMAClass.pick_initial_reference(frames(:,:,1:init_n));
            refProc = preprocess(refImg);
            
            for iter = 1:options.niter
                fprintf('Iteration %d / %d\n', iter, options.niter);
                offsets = zeros(nframes, 2);
                corr_values = zeros(nframes, 1);
                
                for i = 1:nframes
                    frameProc = preprocess(frames(:,:,i));
                    [offset, maxCorr, ~] = RIMA.RIMAClass.grad_corr(refProc, frameProc, ...
                        options.max_shift, options.smooth_sigma);
                    offsets(i, :) = offset;
                    corr_values(i) = maxCorr;
                end
                
                aligned_frames = zeros(size(frames), 'like', frames);
                for i = 1:nframes
                    aligned_frames(:, :, i) = RIMA.RIMAClass.shift_frame(frames(:, :, i), ...
                        offsets(i, 2), offsets(i, 1));
                end
                
                nmax = max(2, floor(nframes * (1 + iter) / (2 * options.niter)));
                [~, isort] = sort(corr_values, 'descend');
                isort = isort(1:nmax);
                mean_offset = mean(offsets(isort, :), 1);
                
                refImg = mean(aligned_frames(:, :, isort), 3);
                
                refImg = RIMA.RIMAClass.shift_frame(refImg, -round(mean_offset(2)), -round(mean_offset(1)));
                refProc = preprocess(refImg);
            end
            
            refImg = cast(refImg, class(frames));
        end
        
        function out = preprocessFrame(img, mask, useMask)
            % Preprocess a frame: convert to double or apply ROI local mean
            if ~useMask
                out = double(img);
                return;
            end
            out = RIMA.RIMAClass.get_roi_local_mean(img, mask);
        end
        
        function refImg = pick_initial_reference(frames)
            % Pick an initial reference image from a stack by measuring
            % pairwise normalized cross-correlations and averaging the
            % most representative frames.
            [Ly, Lx, nFrames] = size(frames);
            reshapedFrames = single(reshape(frames, [], nFrames)');
            reshapedFrames = reshapedFrames - mean(reshapedFrames, 2);
            ccMatrix = reshapedFrames * reshapedFrames';
            normCCMatrix = ccMatrix ./ (sqrt(diag(ccMatrix)) * sqrt(diag(ccMatrix))' + eps);
            numMatches = min(19, nFrames - 1);
            CCsort = sort(normCCMatrix, 2, 'descend');
            bestCC = mean(CCsort(:, 2:(numMatches+1)), 2);
            [~, bestFrameIdx] = max(bestCC);
            [~, indsort] = sort(normCCMatrix(bestFrameIdx, :), 'descend');
            selectedFrameIndices = indsort(1:min(numMatches+1, nFrames));
            refImg = mean(reshapedFrames(selectedFrameIndices, :), 1);
            refImg = reshape(refImg, Ly, Lx);
        end
        
        function frame_shifted = shift_frame(frame, dy, dx)
            % Shift a 2D frame by (dy, dx) using circular shift
            frame_shifted = circshift(frame, [-dy, -dx]);
        end
        
        function [offset, peak, NGC] = grad_corr(fixed, moving, max_shift, smooth_sigma)
            arguments
                fixed {mustBeNumeric}
                moving {mustBeNumeric}
                max_shift (1,1) {mustBeNonnegative} = 0.1
                smooth_sigma (1,1) {mustBeNonnegative} = 1.125
            end
            
            useGPU = RIMA.RIMAClass.canUseGPU();
            
            if ~isa(moving,'single')
                moving = single(moving);
            end
            if ~isa(fixed,'single')
                fixed = single(fixed);
            end
            if useGPU
                moving = gpuArray(moving);
                fixed = gpuArray(fixed);
            end
            % Optionally apply Gaussian smoothing to reduce noise
            if smooth_sigma > 0
                moving = imgaussfilt(moving, smooth_sigma);
                fixed = imgaussfilt(fixed, smooth_sigma);
            end
            
            [Ly, Lx, nFrames] = size(moving);
            [NGC, shift_x, shift_y] = RIMA.RIMAClass.normalizedGradientCorrelation(moving, fixed, useGPU);
            
            % Preallocate outputs
            offset = zeros(nFrames, 2);
            peak = zeros(nFrames, 1);
            
            % Limit the search region based on max_shift (fraction of min dimension)
            if max_shift > 0
                minDim = min(Ly, Lx);
                max_shift_pixels = min(round(max_shift * minDim), floor(minDim / 2));
                center_y = ceil(size(NGC, 1) / 2);
                center_x = ceil(size(NGC, 2) / 2);
                y_range = max(1, center_y - max_shift_pixels) : min(size(NGC, 1), center_y + max_shift_pixels);
                x_range = max(1, center_x - max_shift_pixels) : min(size(NGC, 2), center_x + max_shift_pixels);
                
                for f = 1:nFrames
                    NGC_region = NGC(y_range, x_range, f);
                    [peak_val, idx] = max(NGC_region(:));
                    [row_local, col_local] = ind2sub(size(NGC_region), idx);
                    row = y_range(1) + row_local - 1;
                    col = x_range(1) + col_local - 1;
                    peak(f) = peak_val;
                    x_translation = shift_x(col);
                    y_translation = shift_y(row);
                    offset(f, :) = [-x_translation, -y_translation];
                end
            else
                for f = 1:nFrames
                    NGC_frame = NGC(:,:,f);
                    [peak_val, idx] = max(NGC_frame(:));
                    [row, col] = ind2sub(size(NGC_frame), idx);
                    peak(f) = peak_val;
                    x_translation = shift_x(col);
                    y_translation = shift_y(row);
                    offset(f, :) = [-x_translation, -y_translation];
                end
            end
            
            % Gather results from GPU if used
            if useGPU
                peak = gather(peak);
                offset = gather(offset);
                NGC = gather(NGC);
                shift_x = gather(shift_x);
                shift_y = gather(shift_y);
            end
        end
        
        function [NGC, shift_x, shift_y] = normalizedGradientCorrelation(I1, I2, useGPU)
            % Compute normalized gradient correlation between I1 (moving)
            % and I2 (fixed). Returns the NGC stack and shift coordinate
            % vectors.
            G1 = RIMA.RIMAClass.complexGradientImage(I1);
            G2 = RIMA.RIMAClass.complexGradientImage(I2);
            
            if ndims(I1) == 3
                G1_bar = mean(G1, [1 2]);
            else
                G1_bar = mean(G1, "all");
            end
            G2_bar = mean(G2, "all");
            
            [NGC_numerator, shift_x, shift_y] = RIMA.RIMAClass.fftCorrelation2D(G2 - G2_bar, G1 - G1_bar);
            
            if ndims(I1) == 3
                norm1 = sum(abs(G1 - G1_bar).^2, [1 2]);
            else
                norm1 = sum(abs(G1 - G1_bar).^2, "all");
            end
            norm2 = sum(abs(G2 - G2_bar).^2, "all");
            
            NGC_denominator = sqrt(norm1 .* norm2);
            NGC = NGC_numerator ./ NGC_denominator;
            NGC(~isfinite(NGC)) = 0;
            NGC = real(NGC);
        end
        
        function G = complexGradientImage(I)
            % Compute complex gradient image G = Gx + 1j*Gy
            [Gx, Gy] = imgradientxy(I, 'central');
            G = Gx + 1j * Gy;
        end
        
        function [C, shift_x, shift_y] = fftCorrelation2D(A, B)
            % Compute cross-correlation via FFT between 2D A (fixed) and
            % 2D/3D B (moving). Returns C and shift coordinate vectors.
            arguments
                A   {mustBeNumeric, mustBeNonempty}
                B   {mustBeNumeric, mustBeNonempty}
            end
            
            [Ma, Na] = size(A, [1 2]);
            [Mb, Nb] = size(B, [1 2]);
            
            shift_x = -(Nb-1):(Na-1);
            shift_y = -(Mb-1):(Ma-1);
            
            Mc = Ma + Mb - 1;
            Nc = Na + Nb - 1;
            Mcp = 2^nextpow2(Mc);
            Ncp = 2^nextpow2(Nc);
            
            ABConj = fft2(A, Mcp, Ncp) .* conj(fft2(B, Mcp, Ncp));
            C = ifftshift(ifft2(ABConj));
            C = C(1:Mc, 1:Nc, :);
        end
        
        function available = canUseGPU()
            % Check if a GPU device is available for computations
            try
                available = gpuDeviceCount > 0 && ~isempty(gpuDevice());
            catch
                available = false;
            end
        end
        
        function out = get_roi_local_mean(img, mask)
            % Simple ROI handling: zero out pixels outside the mask
            imgd = double(img);
            out = imgd;
            if ~isempty(mask)
                out(~mask) = 0;
            end
        end
    end
end
