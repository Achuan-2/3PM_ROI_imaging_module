function [dev,status] = connect(resourceID,simulateState)
    if simulateState
        % 仿真模式
        dev = ividev("NIFGEN","",Simulate=true);
        assignin('base','awgDevice',dev);
    else
        % 连接实际设备
        try
            dev = ividev("NIFGEN",resourceID);
        catch
            % 如果报错，dev为空
            msgbox("Can't not connect the device! Please check if the device is turned on or connected ",'Warning','error');
            dev = 'none';
            status = false;
            return
        end
        
    end
    status = true;
