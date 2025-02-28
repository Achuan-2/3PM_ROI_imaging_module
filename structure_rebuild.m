input_path = "D:\SynologyDrive\Microscope-3PM\JixiongSu\AES\20240920_blood\Processed\file_00005_ch1.tif";
imgStack = tiff_read(input_path);
imgStackRebuild =  tiff_rebuild(imgStack);

% 获取标签
t = Tiff(input_path, 'r');
tagstruct = struct();
try
    tagstruct.XResolution = t.getTag('XResolution');
    tagstruct.YResolution = tagstruct.XResolution;
catch
    
end
% 使用fileparts解析输入路径
[pathstr, name, ext] = fileparts(input_path);

% 生成输出文件名
output_name = strcat(name,'_rebuild',ext);

% 生成输出路径
output_path = fullfile(pathstr, output_name);

% 将 newImgStack 保存为 tiff 文件，每一帧分别写入
tiff_save(imgStackRebuild,output_path,tagstruct);


function imgStackCombine =  tiff_rebuild(imgStack)
    % 每十帧合并为一帧
    nFrames = size(imgStack,3); % 获取总帧数
    imageSize = size(imgStack,1); 
    realFrames = floor(nFrames/10); % 需要考虑帧不为10倍整数的情况
    imgStackCombine = zeros(imageSize, imageSize,realFrames);
    colNum = floor(imageSize/10);
    for iframe = 1:realFrames
        temp_frame =  zeros(imageSize, imageSize);
        count = 1; %计数，十帧里的哪一帧
        for i = 1:10
            img = imgStack(:, :, 10*(iframe-1)+count);
            start_f = i;
            if start_f>10
                % 如果i大于10，自动处理
                start_f = start_f -10;
            end

            start_col = (start_f-1)*colNum +1 ;

            if start_f == 10 % 如果是i=10的填充
                temp_frame(:,start_col:end) = img(:,start_col:end);
            else
                fill_col = start_col:start_col+colNum-1;
                temp_frame(:,fill_col) = img(:,fill_col);
            end

            count = count +1;
        end
        imgStackCombine(:,:,iframe) = temp_frame;
        imgStackCombine = int16(imgStackCombine);
    end
end
% function imgStackCombine =  tiff_extract(imgStack)
%     nFrames = size(imgStack,3);
%     imageSize = size(imgStack,1);
%     realFrames = nFrames/10;
%     imgStackCombine = zeros(imageSize, imageSize,realFrames );
% 
%     % 把10帧图片合并为一帧，合并的规则为取第i帧的i:10:512列
%     for iframe = 1:realFrames
%         temp_frame =  zeros(imageSize, imageSize);
%         count = 1;
%         for i = 1:10
%             img = imgStack(:, :, 10*(iframe-1)+count);
%             start = i;
%             if start>10
%                 start = start -10;
%             end
%             fill_col = start:10:imageSize;
%             temp_frame(:,fill_col) = img(:,fill_col);
% 
%             count = count +1;
%         end
%         imgStackCombine(:,:,iframe) = temp_frame;
%     end
% end