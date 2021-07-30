clc;clear all;close all;
FaroOrFringe = 1;

if FaroOrFringe == 0
    [f,path] = uigetfile('*mat');
    load(strcat(path,f));
    X = ptc.Location(:,1)/1000;
    Y = ptc.Location(:,2)/1000;
    Z = ptc.Location(:,3)/1000;
    X = X-mean(X); Y = Y-mean(Y); Z = Z-mean(Z);
    ptc = pointCloud([X Y Z]);
else
    ReadFaroASCII;
    ptc = pointCloud([faroX-.25,faroY-.25,faroZ]);
end



panelnum = 80;
%load file with coefficients and grab them
[f,path] = uigetfile('*mat');
load(strcat(path,f));

coef = archpan3(panelnum+1,2:11);
[fitresult, gof] = FitPanel(coef,ptc);

