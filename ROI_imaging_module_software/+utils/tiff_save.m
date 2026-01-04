function tiff_save(input_img, filepath, tags)
    %tiff_save_lib: Save a 3D image stack as a TIFF volume.
    %
    %   USAGE
    %       tiff_save(img, 'test.tif');
    %       ---
    %       tagstruct = tiff_read_tag('original.tif');
    %       tiff_save(img, 'test.tif', tagstruct);
    %       ---
    %		pixelsize = 512/285; % pix/um
    %		pixelsize = pixelsize*1E4; % pix/cm (there are 1E4 um in a cm)
    %		tag.XResolution = pixelsize;
    %		tag.YResolution = pixelsize;
    %		tiff_save(imgStack, 'test_tifflib.tif',tag);
    %
    %   Input Arguments
    %       input_img     -   the input image,can be 2D or 3D.
    %       filepath      -   Path to the TIFF file to be created.
    %       tagstruct          -   Optional structure containing TIFF file tags.
    %
    
    arguments
        input_img % the input image,can be 2D or 3D.
        filepath string % Path to the TIFF file to be created.
        tags struct = struct() % Optional structure containing TIFF file properties.
    end
    
    if ~ismember(ndims(input_img), [2, 3])
        error('The number of dimensions of the input image must be 2 or 3.');
    end
    
    default_tags = tiff_generate_tagstruct(input_img);
    
    if isempty(fieldnames(tags))
        % Set default TIFF file properties if info is not provided.
        tags = default_tags;
    else
        % 如果本身有传入options，传入的tag和默认tag进行合并
        fields1 = fieldnames(tags);
        fields2 = fieldnames(default_tags);
        % 遍历fields2
        for i = 1:length(fields2)
            % 判断字段是否在fields1中存在
            if ~ismember(fields2{i}, fields1)
                % 如果不存在则将该字段添加到struct1中
                tags.(fields2{i}) = default_tags.(fields2{i});
            end
            
        end
        
    end
    
    s = whos('input_img');
    
    if s.bytes > 3.7628352 * 10 ^ 9 % 2^32-1约等于4GB,但是考虑加上tag后，文件会偏大
        t = Tiff(filepath, 'w8');
    else
        t = Tiff(filepath, 'w');
    end
    
    depth = size(input_img, 3);
    
    % 创建简化版标签 - 删除Software和Artist标签
    tagsSimple = tags;
    % 如果tagsSimple有Software标签，则删除
    if isfield(tagsSimple, 'Software')
        tagsSimple = rmfield(tagsSimple, 'Software');
    end
    % 如果有Artist标签，则删除
    if isfield(tagsSimple, 'Artist')
        tagsSimple = rmfield(tagsSimple, 'Artist');
    end
    
    for d = 1:depth
        % 根据是否是第一帧选择使用完整标签还是简化标签
        if d == 1
            current_tags = tags;  % 第一帧使用完整标签
        else
            current_tags = tagsSimple;  % 其他帧使用简化标签
        end
        
        fields = fieldnames(current_tags);
        
        % 设置TIff标签
        for i = 1:length(fields)
            field = fields{i}; % 当前字段名称
            value = current_tags.(field); % 当前字段的值
            
            % 使用tf.setTag设置TIFF标签
            t.setTag(field, value);
        end
        
        % 写入图片
        t.write(input_img(:, :, d));
        
        if d ~= depth
            % Tiff对象若需要写入多帧图片，需要使用writeDirectory，将IFD指向下一帧，才能继续写入
            t.writeDirectory();
        end
    end
    
    t.close();
end

function tagstruct = tiff_generate_tagstruct(input_img)
    tagstruct.ImageLength = size(input_img, 1);
    tagstruct.ImageWidth = size(input_img, 2);
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    
    switch class(input_img)
        case {'uint8', 'int8'}
            tagstruct.BitsPerSample = 8;
        case {'uint16', 'int16'}
            tagstruct.BitsPerSample = 16;
        case {'uint32', 'int32'}
            tagstruct.BitsPerSample = 32;
        case {'single'}
            tagstruct.BitsPerSample = 32;
        case {'double', 'uint64', 'int64'}
            tagstruct.BitsPerSample = 64;
    end
    
    if ismember(class(input_img), {'uint8', 'uint16', 'uint32', 'logical'})
        tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
    elseif ismember(class(input_img), {'single','double'})
        tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
    else
        tagstruct.SampleFormat = Tiff.SampleFormat.Int;
    end
    tagstruct.ResolutionUnit = Tiff.ResolutionUnit.Centimeter;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
end
