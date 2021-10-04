clc; clear all; close all; closescreen;
%Actual Panel Size

panelPoints = readmatrix("panelPoints.csv");

% add 1 to number of panel you are plotting
panelNum = 69;

x = panelPoints(panelNum, 5:2:11);
y = panelPoints(panelNum, 6:2:12);

PanelX = 49.5;
PanelY = 49.5;
scalingON = 0;
SizeX = 1045;
SizeY = 1045;
while scalingON
   
    sx = input('Enter number of pixels in x');
    if sx == 0
        break;
    end
    sy = input('Enter number of pixels in y');
    if sy == 0
        break;
    end
    closescreen;
    xpoly = [1920/2-sx/2 1920/2-sx/2 1920/2+sx/2 1920/2+sx/2];
    ypoly = [1080/2-sy/2 1080/2+sy/2 1080/2+sy/2 1080/2-sy/2];
    mask = poly2mask(xpoly,ypoly,1080,1920);
    SizeX = sx; SizeY = sy;
    fullscreen(mask,2)
end
x_px2cm = SizeY/PanelY;
y_px2cm = SizeY/PanelY;

x_centered = x-mean(x);
y_centered = y-mean(y);

x_centeredscaled = x_centered*x_px2cm+1920/2;
y_centeredscaled = y_centered*y_px2cm+1080/2;

panelmask = double(poly2mask(x_centeredscaled,y_centeredscaled,1080,1920));
panelmask = insertText(panelmask,[x_centeredscaled(1),y_centeredscaled(1)],'A','TextColor','w','FontSize',20);
fullscreen(panelmask,2);



