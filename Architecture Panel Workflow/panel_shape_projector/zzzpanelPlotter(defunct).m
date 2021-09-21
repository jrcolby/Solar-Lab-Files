% take list of side length and angles and 
% use them to plot a polygon to project onto paper

% Panel 80 info 
% A: 49.122 B: 49.33 C: 42.55 D: 49.348
% AB: 93.18 BC: 86.17 CD: 86.18 DA: 93.83

sideALength = 49.122;
sideBLength = 49.33; 
sideCLength = 42.55;
sideDLength = 49.348;

% angleAB = 93.18;
% angleBC = 86.17;
% angleCD = 86.18;
% angleDA = 93.83;

angleAB = 86.17;
angleBC = 93.18;
angleCD = 93.83;
angleDA = 86.18;

% stick side c to y axis, point BC is 0,0
pointBCx = 0;
pointBCy = 0;

% point CD is (0, (side C length))
pointCDx = 0;
pointCDy = sideCLength;

% point AB is polar coordinate to convert to cartesian
% Add 90 to start at y axis as 0
% 90 - BC angle, radius length = side B
[pointABx, pointABy] = pol2cart(deg2rad(90 - angleBC), sideBLength);

% point AD is polar 
% subtract 90 to start at y axis
% (CD angle) - 90, radius length = side D
% add length of C to y to raise to correct y position
[pointADx, pointADy] = pol2cart(deg2rad(-(90 - angleCD)), sideCLength);
pointADy = pointADy + sideCLength; 

disp("Point BC : " + pointBCx + " " + pointBCy);
disp("Point CD : " + pointCDx + " " + pointCDy);
disp("Point AB : " + pointABx + " " + pointABy);
disp("Point AD : " + pointADx + " " + pointADy);

%use readmatrix

% plot with polyshape
pgon = polyshape(...
[pointBCx pointCDx pointADx pointABx], ...
[pointBCy pointCDy pointADy pointABy]);

