clc;clear all;close all;
%% This function takes in fringe or faro measurements and loads them into pointclouds
% Fringe = 0, Faro = 1
faro = 1;
fringe = 0;

FaroOrFringe = faro;

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

%load file with coefficients and grab them using userinterface
%[f,path] = uigetfile('*mat');
 %load(strcat(path,f)); 
 
panelnum = 79;

 % hard coded architectural panel spreadsheet filename
load('archpan3.mat');
coef = archpan3(panelnum+1,2:11);
[fitresult, gof] = FitPanel(coef,ptc);

