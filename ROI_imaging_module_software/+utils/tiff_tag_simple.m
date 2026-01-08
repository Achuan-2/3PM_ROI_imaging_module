function tagsSimple= tiff_tag_simple(tags)
    tagsSimple = tags;
    % 如果tagsSimple有Software标签，则删除
    if isfield(tagsSimple, 'Software')
        tagsSimple = rmfield(tagsSimple, 'Software');
    end
    % 如果有Artist标签，则删除
    if isfield(tagsSimple, 'Artist')
        tagsSimple = rmfield(tagsSimple, 'Artist');
    end
end