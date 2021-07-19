function Z_res_mean = actuatorPositions(panelnum,X,Y,ZFaro)
    %This function takes in a panel number from the spreadsheet of
    %architecture panel coefficients, and the XY locations of the actuators
    %on the mold, and returns the actuator heights
    X = X(:)/1000;
    Y = Y(:)/1000;
    ZFaro = ZFaro/1000;
    % Subtract coordinates of center tile (81) to align shape with origin
    X = X-X(81);
    Y = Y-Y(81);
    ZFaro = ZFaro-ZFaro(81);
    
   %/ offset = max(ZFaro); <-- this var currently unused
    [f,path] = uigetfile('*mat');
    load(strcat(path,f));

    coef = archpan3(panelnum+1,2:11);
    syms('x','y')
    
    % this formula is unused as first two coefficients are just tip/tilt
    %f = coef(1)+coef(2)*x+coef(3)*y+coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;

    f = coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;
    f = matlabFunction(f);
    Zideal = f(X,Y);
    scatter3(X,Y,ZFaro);
    Zres = Zideal-ZFaro;
    
    % subtract max of residuals from all residuals
    % in order to make all residuals negative (tightening down on mold)
    %Zres = Zres - max(Zres);
    
    Z_res_mean = Zres - mean(Zres); 
    
    % we ignore the first and last row of the mold when calculating RMS
    % as they aren't part of the final panels shape (and those rows are
    % broken in the current mold)
    
    Z_res_adj = Z_res_mean(9:72);
    
    rmse = 1e6 * rms(Z_res_adj);
    

    disp("RMSE = " + rmse);
    
%     rmse2 = 1e6 * rms(Zres);
%     
%     disp("RMSE without mean " + rmse2 );
    
    figure
    scatter3(X,Y,Zideal); hold on;
    scatter3(X,Y,ZFaro);        
    legend('ideal','Faro')
    figure
    scatter3(X,Y,Zres)
end