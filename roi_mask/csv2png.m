filename = '32off32on.csv';
[path,name,ext] = fileparts(filename);
a = readtable(filename);
b = table2array(a);
imwrite(b,[name,'.png']);