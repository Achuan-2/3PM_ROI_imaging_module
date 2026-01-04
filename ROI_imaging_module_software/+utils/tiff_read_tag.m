function tagstruct = tiff_read_tag(input)
    %tiff_read_tag - 读取 Tiff 图像的信息.
    %
    %   USAGE
    %       tagstruct = tiff_read_tag(filepath)
    %       tagstruct = tiff_read_tag(tiffObject)
    %
    %   INPUT PARAMETERS
    %       input               -   图像文件的路径或已经打开的Tiff对象
    %
    %   OUTPUT PARAMETERS
    %       tagstruct         -   返回图像信息的struct数组
    
    % 判断输入是路径还是Tiff对象
    if ischar(input) || isstring(input)
        % 输入是路径，创建新的Tiff对象
        t = Tiff(input, 'r');
        needClose = true;
    elseif isa(input, 'Tiff')
        % 输入已经是Tiff对象
        t = input;
        needClose = false;
    else
        error('输入参数必须是文件路径或Tiff对象');
    end

    tagNames = {
    'ImageLength'
    'ImageWidth'
    'ImageDescription'
    'Artist'
    'ResolutionUnit'
    'XResolution'
    'YResolution'
    'Orientation'
    'Photometric'
    'BitsPerSample'
    'SamplesPerPixel'
    'SampleFormat'
    'RowsPerStrip'
    'PlanarConfiguration'
    'Software'
    };
    
    tagstruct = struct();
    % 循环获取每个tag的值
    for k = 1:length(tagNames)
        try
            tagName = tagNames{k};
            tagValue = t.getTag(tagName);
            tagstruct.(tagName) = tagValue;
        catch
            %fprintf('Tag %s cannot be retrieved.\n', tagNames{k});
        end
    end
    
    % 只有当我们创建了新的Tiff对象时才关闭它
    if needClose
        t.close();
    end
end