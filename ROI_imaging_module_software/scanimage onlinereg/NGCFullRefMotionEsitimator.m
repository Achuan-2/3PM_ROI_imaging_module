% this code was developed by Marius Pachitariu, Carsen Stringer and Georg Jaindl

classdef NGCFullRefMotionEsitimator < scanimage.interfaces.IMotionEstimator
    %% Abstract Property realization
    properties (SetAccess = immutable)
        zs;
        channels;
    end
    
    properties (Hidden, Constant)
        eps0 = single(1e-10);
    end
    
    %% User properties
    properties (SetObservable)
        subPixel = 10;
    end
    
    %% Internal properties
    properties (SetAccess = private, Hidden)
        cfRefImg_gpu
        maskMul_gpu
        denomRef_gpu
        sz
        szPad
        szPadHalf
    end
    
    %% Lifecycle
    methods
        function obj=NGCFullRefMotionEsitimator(referenceRoiData)
            obj = obj@scanimage.interfaces.IMotionEstimator(referenceRoiData);
            
            hRoi = referenceRoiData.hRoi;
            obj.zs = referenceRoiData.zs;
            scanfields = arrayfun(@(z)hRoi.get(z),obj.zs,'UniformOutput',false);
            assert(~isempty(scanfields),'Incorrect z selection for ROI'); % sanity check
            
            % current ROI restrictions for this estimator:
            %  - the pixel resolution at each z needs to be the same
            %  - the scanfield at each z needs to be the same
            %  - only one channel can be selected for motion estimation
            if ~isscalar(scanfields)
                affines = cellfun(@(scanfield)scanfield.affine,scanfields,'UniformOutput',false);
                pixelResolutionsXY = cellfun(@(scanfield)scanfield.pixelResolutionXY,scanfields,'UniformOutput',false);
                assert(isequal(affines{:}),'All scanfields in the ROI need to have the same geometry');
                assert(isequal(pixelResolutionsXY{:}),'All scanfields in the ROI need to have the same pixel resolution');
            end
            
            channels = referenceRoiData.channels;
            assert(numel(channels) == 1,'Estimator %s does not support multiple channels',class(obj));
            obj.channels = channels;
            
            obj.preprocessVolume(referenceRoiData);
        end
        
        function delete(~)
            % No-Op
        end
    end
    
    %% Abstract Methods realization
    methods (Access = protected)
        function startInternal(~)
            % No-Op
        end
        
        function abortInternal(~)
            % No-Op
        end
        
        function motion_estimator_result = estimateMotionInternal(obj,roiData)
            chIdx = find(roiData.channels == obj.channels);
            zIdx = find(roiData.zs == obj.zs);
            if isempty(chIdx) || isempty(zIdx) % reference channel or reference z is currently not imaged
                motion_estimator_result = [];
                return
            end
            
            imData = roiData.imageData{chIdx}{1};
            [dr,confidence,correlation] = obj.estimationFcn(imData,zIdx);
            motion_estimator_result = scanimage.components.motionEstimators.estimatorResults.SimpleMotionEstimatorResult(obj,roiData,dr,confidence,correlation);
        end
    end
    
    %% Internal Methods
    methods
        function preprocessVolume(obj,referenceRoiData)
            import scanimage.components.motionEstimators.suite2P.*
            
            maskSlope = 2; % for tapering mask
            smoothSigma = 1.15; % for smoothing filter, to low-pass shot noise
            
            channelidx = 1;
            Z = referenceRoiData.imageData{channelidx}; % get first and only channel
            Z = cat(3, Z{:});
            Z = single(Z); % ensure datatype single
            
            obj.sz = [size(Z,1), size(Z,2), size(Z,3)]; % size(Z) does not return 3rd dim if 3rd dim is one
            nZs = obj.sz(3);
            
            % Z-score the reference stack
            Z  = bsxfun( @minus,   Z, mean(reshape(Z,[],1,nZs)) );
            Z  = bsxfun( @rdivide, Z, mean(reshape(Z.^2,[],1,nZs),1).^0.5 );
            
            % calculate optimal fft sizes for performance
            obj.szPad(1) = most.util.nextCufftSize(obj.sz(1), 1, 'even');
            obj.szPad(2) = most.util.nextCufftSize(obj.sz(2), 1, 'even');
            obj.szPad(3) = obj.sz(3);
            obj.szPadHalf = [floor(obj.szPad(1:2)/2)+1 obj.szPad(3)];
            
            % sliding average of z-stack
            refImg = zeros(size(Z),'like',Z);
            for zIdx = 1:nZs
                itarget = zIdx + (-2:2);
                outOfBoundsMask = itarget < 1 | itarget > nZs;
                itarget(outOfBoundsMask) = [];
                refImg(:,:,zIdx) = mean(Z(:,:,itarget), 3);
            end
            
            % multiplicative mask for FFT tapering masks
            [mm, nn] = ndgrid(1:obj.sz(1), 1:obj.sz(2));
            mm = abs(mm - mean(mm(:)));
            nn = abs(nn - mean(nn(:)));
            Mmax = max(mm(:)) - 4;
            Nmax = max(nn(:)) - 4;
            maskMul = single(1./(1 + exp((mm - Mmax)/maskSlope)) ./(1 + exp((nn - Nmax)/maskSlope)));
            
            % Smoothing filter in frequency domain to apply  after phase correlation
            hgm = exp(-(((0:obj.sz(1)-1) - fix(obj.sz(1)/2))/smoothSigma).^2);
            hgn = exp(-(((0:obj.sz(2)-1) - fix(obj.sz(2)/2))/smoothSigma).^2);
            hg  = single(hgm'*hgn);
            fhg = fft2(ifftshift(hg/sum(hg(:))),obj.szPad(1),obj.szPad(2)); % filter in frequency domain
            fhg = real(fhg);
            
            % Compute complex gradient images for reference stack
            % and prepare FFTs for normalized gradient correlation
            nZs = obj.sz(3);
            Gref = zeros([obj.sz(1) obj.sz(2) nZs],'like',refImg);
            for zIdx = 1:nZs
                Gref(:,:,zIdx) = complexGradientImage(refImg(:,:,zIdx));
            end
            
            % subtract mean per z and compute energy (denominator)
            Gref_bar = mean(reshape(Gref,[],1,nZs),1);
            Gref_zero = bsxfun(@minus,Gref,Gref_bar);
            denomRef = sqrt(sum(abs(Gref_zero).^2,[1 2])); % 1 x 1 x nZs
            
            % FFT of reference gradient (conj) -> numerator terms
            cfRefImg = conj(fft2(Gref_zero,obj.szPad(1),obj.szPad(2)));
            cfRefImg = bsxfun(@times,cfRefImg,fhg); % filter
            
            % transfer to GPU
            obj.cfRefImg_gpu = gpuArray( cfRefImg(1:obj.szPadHalf(1),:,:) ); % only store half in first dim
            obj.maskMul_gpu  = gpuArray(maskMul);
            obj.denomRef_gpu = gpuArray(reshape(denomRef,1,1,[]));
        end
        
        function [dr,confidence,correlation] = estimationFcn(obj,image,zidx)
            % transfer image to GPU
            image = single(image);
            image_gpu = gpuArray(image);
            
            % apply multiplicative mask (tapering)
            image_gpu = obj.maskMul_gpu .* image_gpu;
            
            % compute complex gradient of the input image
            Gimg = complexGradientImage(image_gpu);
            
            % subtract mean and compute denominator for input
            Gimg_bar = mean(Gimg(:));
            Gimg_zero = Gimg - Gimg_bar;
            denomImg = sqrt(sum(abs(Gimg_zero).^2,'all'));
            
            % fourier transform of the input gradient
            image_fft_gpu = fft2(Gimg_zero,obj.szPad(1),obj.szPad(2)); % pad fft2 for performance
            image_fft_gpu = image_fft_gpu(1:obj.szPadHalf(1),:); % store half
            
            % cross correlation numerator: multiply input FFT with conj FFT of reference gradient
            corrMap_gpu = bsxfun(@times,obj.cfRefImg_gpu,image_fft_gpu);
            corrMap_gpu = ifft2(corrMap_gpu,obj.szPad(1),obj.szPad(2),'symmetric'); % symmetric ifft2 returns real values
            
            % Normalize by product of norms to get normalized gradient correlation (NGC)
            denomProd = obj.denomRef_gpu * denomImg; % 1x1xNz
            corrMap_gpu = bsxfun(@rdivide, corrMap_gpu, (denomProd + obj.eps0));
            
            % get indices of correlation peak
            [cmax_gpu,cmax_idx_gpu] = max(corrMap_gpu(:));
            cmax = gather(cmax_gpu); % retrieve from GPU
            cmax_idx = gather(cmax_idx_gpu); % retrieve from GPU
            [Imax,Jmax,Zmax] = ind2sub(obj.szPad,cmax_idx);
            
            if obj.subPixel > 0
                % get volume around the peak
                spline_base = 5; % base for spline interpolation
                bb = (-spline_base:spline_base);
                
                II = mod(Imax+bb-1,obj.szPad(1))+1; % make circular
                JJ = mod(Jmax+bb-1,obj.szPad(2))+1; % make circular
                ZZ = mod(Zmax+bb-1,obj.szPad(3))+1; % make circular to avoid overflow
                corrClip = gather( corrMap_gpu(II, JJ, ZZ) ); % retrieve volume around correlation peak from GPU
                
                % upsample volume around peak
                [IIg,JJg,ZZg] = ndgrid(bb, bb, bb);
                F = griddedInterpolant(IIg,JJg,ZZg,corrClip,'spline');
                subPixels_ = linspace(-1,1,2*obj.subPixel+3); % upsample +-one pixel around peak only
                [IIu,JJu,ZZu] = ndgrid(subPixels_,subPixels_,subPixels_);
                corrClip_up = F(IIu,JJu,ZZu);
                
                % find correlation peak in upsampled volume
                [cmax,idx] = max(corrClip_up(:));
                [Imax_u,Jmax_u,Zmax_u] = ind2sub(size(corrClip_up),idx);
                IsubPix = IIu(Imax_u,Jmax_u,Zmax_u);
                JsubPix = JJu(Imax_u,Jmax_u,Zmax_u);
                ZsubPix = ZZu(Imax_u,Jmax_u,Zmax_u);
            else
                IsubPix = 0;
                JsubPix = 0;
                ZsubPix = 0;
            end
            
            % calculate dI, dJ taking fftshift into account
            dI = most.idioms.ifthenelse(Imax>ceil(obj.szPad(1)/2),Imax-obj.szPad(1)-1,Imax-1);
            dJ = most.idioms.ifthenelse(Jmax>ceil(obj.szPad(2)/2),Jmax-obj.szPad(2)-1,Jmax-1);
            Zmax = Zmax + ZsubPix;
            
            % calculate dx,dy,dz
            dx = dI + IsubPix;
            dy = dJ + JsubPix;
            
            if numel(obj.zs) > 1
                dz = obj.zs(zidx) - interp1(1:numel(obj.zs),obj.zs,Zmax,'linear','extrap');
            else
                dz = 0;
            end
            
            dr = [dx dy dz];
            
            % calculate correlation side projections
            cii_gpu = max(corrMap_gpu,[],2);
            cjj_gpu = max(corrMap_gpu,[],1);
            
            % fetch data from the GPU
            cii = gather(cii_gpu);
            cjj = gather(cjj_gpu);
            cii = permute(cii,[1 3 2]);
            cjj = permute(cjj,[2 3 1]);
            
            czz = max(cii,[],1);
            corrZmaxIdx = min(max(1,round(Zmax)),size(cii,2));
            cii = cii(:,corrZmaxIdx);
            cjj = cjj(:,corrZmaxIdx);
            
            cii = fftshift(cii,1);
            cjj = fftshift(cjj,1);
            
            cii = unpadCorrelation(cii,obj.sz(1));
            cjj = unpadCorrelation(cjj,obj.sz(2));
            
            confidence = repmat(cmax,1,3);
            correlation = {cii,cjj,czz};
            
            function cc = unpadCorrelation(cc,sz)
                dpad = numel(cc)-sz;
                if dpad > 0
                    cc = cc(1+floor(dpad/2):end-ceil(dpad/2));
                else
                    cc = [ nan(ceil(-dpad/2),1); cc; nan(floor(-dpad/2),1) ];
                end
            end
        end
    end
    
    %% Property Getter/Setter
    methods
        function set.subPixel(obj,val)
            validateattributes(val,{'numeric'},{'scalar','integer','nonnegative'});
            obj.subPixel = val;
        end
    end
    
    %% Static methods
    methods (Static)
        function obj = loadobj(s)
            obj = scanimage.components.motionEstimators.NGCFullRefMotionEsitimator(s.roiData);
            obj.enable = s.enable;
            obj.plotPerformance = s.plotPerformance;
        end
        
        function checkSystemRequirements()
            persistent gpuAvailable
            if isempty(gpuAvailable)
                gpuAvailable = most.util.gpuComputingAvailable; % buffer for performance
            end
            
            assert(gpuAvailable,'''%s'' requires a GPU for processing. No compatible GPU was found in this computer.',mfilename('class'));
        end
    end
end
% Helper: compute complex gradient image (works with gpuArray)
function G = complexGradientImage(I)
    [M,N] = size(I);
    hx = [0.5 0 -0.5];
    hy = hx.';
    
    % conv2 supports gpuArray automatically
    Gx = [I(:,2) - I(:,1), conv2(I,hx,'valid'), I(:,N) - I(:,N-1)];
    Gy = [I(2,:) - I(1,:); conv2(I,hy,'valid'); I(M,:) - I(M-1,:)];
    
    G = Gx + 1j * Gy;
end

%--------------------------------------------------------------------------%
% NGCFullRefMotionEsitimator.m                                                  %
% Copyright � 2019 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage is licensed under the Apache License, Version 2.0              %
% (the "License"); you may not use any files contained within the          %
% ScanImage release  except in compliance with the License.                %
% You may obtain a copy of the License at                                  %
% http://www.apache.org/licenses/LICENSE-2.0                               %
%                                                                          %
% Unless required by applicable law or agreed to in writing, software      %
% distributed under the License is distributed on an "AS IS" BASIS,        %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. %
% See the License for the specific language governing permissions and      %
% limitations under the License.                                           %
%--------------------------------------------------------------------------%
