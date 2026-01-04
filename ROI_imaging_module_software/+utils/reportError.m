% 优化异常处理
function reportError(ME)
    % 折叠代码报错位置
    errorReport = ME.getReport('extended');
    errorReport =  matlab.net.base64encode(unicode2native(errorReport, 'UTF-8'));
    errLink = ['<a href ="matlab:fprintf(2,''\n%s\n'', '...
        'native2unicode(matlab.net.base64decode(''' errorReport '''),''UTF-8''));">'...
        'View detailed error information</a>.'];
  
  
    % 点击自动清空窗口
    clcLink = '<a href ="matlab:clc">Clear command window</a>.';
    fprintf(2,'%s %s\n' ,errLink,clcLink);
end