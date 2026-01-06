function imgStack = scanphase_correct(imgStack,offset)
    if offset > 0
        imgStack(2:2:end,offset+1:end,: ) = imgStack(2:2:end,1:end-offset,:);
    else
        imgStack(2:2:end,1:end+offset,:)  = imgStack(2:2:end, 1-offset:end,:);
    end
end