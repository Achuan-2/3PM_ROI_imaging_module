function output_enable(obj)
    try
        initiateGeneration(obj);
        enable = true;
        configureOutputEnabled(obj,'0',enable);
    catch ErrorInfo
        msgbox(ErrorInfo.message,'Warning','error');
        return
    end
end