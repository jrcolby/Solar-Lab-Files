function Zres = actuatorPositions(panelnum,X,Y,ZFaro)
    %This function takes in a panel number from the spreadsheet of
    %architecture panel coefficients, and the XY locations of the actuators
    %on the mold, and returns the actuator heights
    X = X(:)/1000; Y = Y(:)/1000;ZFaro = ZFaro/1000;
    X = X-X(57);
    Y = Y-Y(57);
    ZFaro = ZFaro-ZFaro(57);
    
    offset = max(ZFaro);
    [f,path] = uigetfile('*mat');
    load(strcat(path,f));

    coef = archpan3(panelnum+1,2:11);
    syms('x','y')
    %f = coef(1)+coef(2)*x+coef(3)*y+coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;

    f = coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;
    f = matlabFunction(f);
    Zideal = f(X,Y);
    scatter3(X,Y,ZFaro);
    Zres = Zideal-ZFaro;
    Zres = Zres - max(Zres);
    
    Z_res_adj = Zres - mean(Zres); 
    rmse = 1e3 * rms(Z_res_adj);
    disp("RMSE = " + rmse);
    
    figure
    scatter3(X,Y,Zideal); hold on;
    scatter3(X,Y,ZFaro);        
    legend('ideal','Faro')
    figure
    scatter3(X,Y,Zres)
end