clc; clear all; close all;
[fname, path] = uigetfile('*.txt');
fin = fopen(strcat(path,fname),'r+');
i = 1;
datatrigger = 0;
while ~feof(fin)
    
    s = fgetl(fin);
    
        
    while contains(s, '  ')
      s = strrep(s, '  ', ' ');
    end
   
    s = split(s,' ');
   
    if i > 1
        Data(i-1,:) = [str2num(s{2}) str2num(s{3}) str2num(s{4})];
    end
    i = i+1;


    
end

fclose(fin);

X = Data(:,1);
Y = Data(:,2);
Z = Data(:,3);



