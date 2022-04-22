function [Z_res_adjusted] = actuatorPositions(panelnum,X,Y,ZFaro)
    %This function takes in a panel number from the spreadsheet of
    %architecture panel coefficients, and the XY locations of the actuators
    %on the mold, and returns the actuator heights

    % Subtract coordinates of center tile (21) to align shape with origin
    
%     X = X-X(21);
%     Y = Y-Y(21);
%     ZFaro = ZFaro-ZFaro(21);

    % HARDCODED PANEL EQUATIONS, CHANGE IF UPDATED
    load("archpan1001.mat");
    
    % get constants from spreadsheet of panel equation information
    coef = archpan1001((panelnum+1),2:11);
    syms('x','y')
    
    % this formula is unused as first two coefficients are just tip/tilt
    %f = coef(1)+coef(2)*x+fsurf(f, [-25 ,25]);coef(3)*y+coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;

    % Faro arm X Y and Z are in mm, but panel equation is in centimeters,
    % adjust accordingly by dividing mm by 10
    X_centimeters = X / 10;
    Y_centimeters = Y / 10;
    Z_centimeters = ZFaro / 10;
    
    % Plugin constants into third-order polynomial equation
    f = coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;
    
    % make surface plot of panel (comment line below out to stop displaying
    fsurf(f, [-25 ,25]);
    
    % turn equation f into matlab function
    f = matlabFunction(f);
    
    % get Z heights of each actuator for equation
    Zideal = f(X_centimeters,Y_centimeters);
    
    % residuals are difference between equation and actual measurements
    Zres = Zideal-Z_centimeters;
    
    % uncomment to
    % subtract the mean of all residuals from each residual
    % in order to minimize amount each needs to move
    
    Z_res_adjusted = Zres - mean(Zres);
    
    % uncomment to subtract each res from the max of all residuals,
    % in order to make all residuals negative (only pulling spring down)
   
    %Z_res_adjusted = Zres - max(Zres);
     
     
    % uncomment to scatterplot magnitude of each residual
    %scatter3(X,Y,Z_res_adjusted);
    
    % put vectors in workspace in order to inspect them if neccesary
    assignin('base','zIdeals', Zideal);
    assignin('base','raw_residuals', Zres);
    assignin('base','residuals_minus_mean', Z_res_adjusted);
   

    % We want our output residuals to be in mm, multiply by 10
    answer = Z_res_adjusted * 10;

    % THIS IS THE VECTOR TO COPY PASTE INTO MOLD ADJUSTMENT SPREADSHEET
    assignin('base','spreadsheet_residuals', answer);

    % we ignore the first and last row of the mold when calculating RMS
    % as they aren't part of the final panels shape (and those rows are
    % broken in the current mold) 
    Z_res_for_RMS = Z_res_adjusted(1:16);
    Z_res_for_RMS(5) = [];
    Z_res_for_RMS(13) = [];
    assignin('base','rms_residuals', Z_res_for_RMS);

    % this RMS is in cm, adjust to microns
    rmse = 10000 * rms(Z_res_for_RMS-mean(Z_res_for_RMS));
%     disp("RMSE = " + rmse);
    
% uncomment this code to display graphs of ideal z positions vs 
% measured z
%     figure
%     scatter3(X,Y,Zideal); hold on;
%     scatter3(X,Y,Z_centimeters);        
%     legend('ideal','Faro')
end


   % Z_res_mepanelPoints = readmatrix("panelPoints.csv");

% add 1 to number of panel you are plotting
% panelNum = 81;
% 
% x11 = panelPoints(panelNum, 5);
% y11 = panelPoints(panelNum, 6);
% x10 = panelPoints(panelNum,7);
% y10 = panelPoints(panelNum,8);
% x00 = panelPoints(panelNum,9);
% y00 = panelPoints(panelNum,10);
% x01 = panelPoints(panelNum,11);
% y01 = panelPoints(panelNum,12);
%     
% 
% plot([x10,x11],[y10,y11],"-red",...
%     [x10,x00],[y10,y00],"-blue",...
%     [x01,x00],[y01,y00],"-cyan",...
%     [x01,x11],[y01,y11],"-blue");
% 
% xlim([-30 30]);
% ylim([-30 30]);
