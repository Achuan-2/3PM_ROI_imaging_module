function mask = stroke_to_mask(stroke,img_size)
    %STROKE_TO_MASK create a mask by stroke which is made of points
    
    arguments
        stroke (:,2) double
        img_size (1,2) double
    end
    mask = poly2mask(stroke(:,1), stroke(:,2),img_size(1),img_size(2));
end

