
[f,path] = uigetfile('*mat');
load(strcat(path,f));

X = -.25:.01:.25;
Y = X;
[X,Y] = meshgrid(X,Y);

panelnum = 79;
coef = archpan3(panelnum+1,2:11);
syms('x','y')
f = coef(1) + coef(2)*x + coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;
f = matlabFunction(f);
Z = f(X,Y);

XYZ = [X(:) Y(:) Z(:)];

pcEquation = pointCloud(XYZ);
pcshow(pcEquation)


pcFaro = pointCloud(faroX,faroY,faroZ);

