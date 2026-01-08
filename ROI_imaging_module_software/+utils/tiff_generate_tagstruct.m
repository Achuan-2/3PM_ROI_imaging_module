function outputTags = tiff_generate_tagstruct(input_img, inputTags)
    % tiff_generate_outputTags - 生成TIFF文件的tag结构体
    %
    % Syntax: outputTags = tiff_generate_outputTags(input_img, xResolution, yResolution)
    %
    % Inputs:
    %    input_img - 输入图像
    %    xResolution - X方向分辨率（可选）
    %    yResolution - Y方向分辨率（可选）
    %
    % Outputs:
    %    outputTags - 生成的TIFF tag结构体
    %
    % Example:
    %    tiff_generate_outputTags(sampleFrame, 300, 300)

    arguments
        input_img
        inputTags = struct()
    end

    outputTags.ImageLength = size(input_img, 1);
    outputTags.ImageWidth = size(input_img, 2);
    outputTags.Photometric = Tiff.Photometric.MinIsBlack;

    switch class(input_img)
        case {'uint8', 'int8'}
            outputTags.BitsPerSample = 8;
        case {'uint16', 'int16'}
            outputTags.BitsPerSample = 16;
        case {'uint32', 'int32'}
            outputTags.BitsPerSample = 32;
        case {'single'}
            outputTags.BitsPerSample = 32;
        case {'double', 'uint64', 'int64'}
            outputTags.BitsPerSample = 64;
    end

    if ismember(class(input_img), {'uint8', 'uint16', 'uint32', 'logical'})
        outputTags.SampleFormat = Tiff.SampleFormat.UInt;
    else
        outputTags.SampleFormat = Tiff.SampleFormat.Int;
    end

    outputTags.ResolutionUnit = Tiff.ResolutionUnit.Centimeter;

    outputTags.SamplesPerPixel = 1;
    outputTags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;


    if ~isempty(fieldnames(inputTags))
        % 如果本身有传入options，传入的tag和默认tag进行合并
        fields1 = fieldnames(outputTags);
        fields2 = fieldnames(inputTags);
        % 遍历fields2
        for i = 1:length(fields2)
            % 判断字段是否在fields1中存在
            if ~ismember(fields2{i}, fields1)
                % 如果不存在则将该字段添加到struct1中
                outputTags.(fields2{i}) = inputTags.(fields2{i});
            end
        end
    end
end
