pyfolder ='python';
if count(py.sys.path,fullfile(pwd,pyfolder)) == 0
    insert(py.sys.path,int32(0),fullfile(pwd,pyfolder));
end
