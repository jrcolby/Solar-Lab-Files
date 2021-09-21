panelPoints = readmatrix("panelPoints.csv");

% add 1 to number of panel you are plotting
panelNum = 81;

x11 = panelPoints(panelNum, 5);
y11 = panelPoints(panelNum, 6);
x10 = panelPoints(panelNum,7);
y10 = panelPoints(panelNum,8);
x00 = panelPoints(panelNum,9);
y00 = panelPoints(panelNum,10);
x01 = panelPoints(panelNum,11);
y01 = panelPoints(panelNum,12);
    

plot([x10,x11],[y10,y11],"-red",...
    [x10,x00],[y10,y00],"-blue",...
    [x01,x00],[y01,y00],"-cyan",...
    [x01,x11],[y01,y11],"-blue");

xlim([-30 30]);
ylim([-30 30]);


