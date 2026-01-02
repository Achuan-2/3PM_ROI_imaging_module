function normalizeed_img = im_normalize(img,ymin,ymax)
    arguments
        img; %输入图像
        ymin = 0;
        ymax =255;
    end
	xmax = max(max(img)); %求得InImg中的最大值
	xmin = min(min(img)); %求得InImg中的最小值
	normalizeed_img = round((ymax-ymin)*(img-xmin)/(xmax-xmin) + ymin); %归一化并取整
end