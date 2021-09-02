function Z_res_mean = actuatorPositions(panelnum,X,Y,ZFaro)
    %This function takes in a panel number from the spreadsheet of
    %architecture panel coefficients, and the XY locations of the actuators
    %on the mold, and returns the actuator heights
   % X = X(:)/1000;
   % Y = Y(:)/1000;
   % ZFaro = ZFaro/1000;freeFitResult, [xData, yData], zData );
    % Subtract coordinates of center tile (81) to align shape with origin
    X = X-X(21);
    Y = Y-Y(21);
    ZFaro = ZFaro-ZFaro(21);
    
   %/ offset = max(ZFaro); <-- this var currently unused
    [f,path] = uigetfile('*mat');
    load(strcat(path,f));

    coef = archpan3(panelnum+1,2:11);
    syms('x','y')
    
    % this formula is unused as first two coefficients are just tip/tilt
    %f = coef(1)+coef(2)*x+coef(3)*y+coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;

    f = coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;
    fsurf(f, [-2 2]);
    f = matlabFunction(f);
    Zideal = f(X,Y);
   
    
    Zres = Zideal-ZFaro;
    
    % subtract max of residuals from all residuals
    % in order to make all residuals negative (tightening down on mold)
    %Zres = Zres - max(Zres);
    
    Z_res_mean = Zres - mean(Zres); 
    
    % Multiply by 1000 to change from meters to millimeters for spreadsheet

    %scatter3(X,Y,Z_res_mean);
    assignin('base','zIdeals', Zideal);
    assignin('base','rowresiduals', Zres);
   
    
    % we ignore the first and last row of the mold when calculating RMS
    % as they aren't part of the final panels shape (and those rows are
    % broken in the current mold)
    
    Z_res_adj = Z_res_mean(1:16);
    Z_res_adj(5) = [];
    Z_res_adj(13) = [];
    assignin('base','residuals_for_rms', Z_res_adj);

    
    
    rmse = 1e6 * rms(Z_res_adj);
    
    
    disp("RMSE = " + rmse);
    Z_res_mean = Z_res_mean * 1000;
    assignin('base','residuals_for_spreadsheet', Z_res_mean);
%     rmse2 = 1e6 * rms(Zres);
%     
%     disp("RMSE without mean " + rmse2 );
    
%     figure
%     scatter3(X,Y,Zideal); hold on;
%     scatter3(X,Y,ZFaro);        
%     legend('ideal','Faro')
%     figure
%     scatter3(X,Y,Zres)
end