function Z_res_mean = actuatorPositions(panelnum,X,Y,ZFaro)
    %This function takes in a panel number from the spreadsheet of
    %architecture panel coefficients, and the XY locations of the actuators
    %on the mold, and returns the actuator heights

    % Subtract coordinates of center tile (21) to align shape with origin
    
    X = X-X(21);
    Y = Y-Y(21);
    ZFaro = ZFaro-ZFaro(21);
 
    %commented this out and hardcoded panel equation spreadsheet
    %[f,path] = uigetfile('*mat');
    %load(strcat(path,f));

    % HARDCODED PANEL EQUATIONS, CHANGE IF UPDATED
    load("PANEL_EQUATION_CONSTANTS_10_01_21.mat");
    
    coef = PANEL_EQUATION_CONSTANTS(panelnum+2,2:11);
    syms('x','y')
    
    % this formula is unused as first two coefficients are just tip/tilt
    %f = coef(1)+coef(2)*x+coef(3)*y+coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;

    % Faro arm X Y and Z are in mm, but panel equation is in centimeters,
    % adjust
    X_centimeters = X / 10;
    Y_centimeters = Y / 10;
    Z_centimeters = ZFaro / 10;
    
    
    f = coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;
    fsurf(f, [-25 ,25]);
    f = matlabFunction(f);
    
    Zideal = f(X_centimeters,Y_centimeters);
    
    Zres = Zideal-Z_centimeters;
    
    % subtract max of residuals from all residuals
    % in order to make all residuals negative (tightening down on mold)
    %Zres_negative = Zres - max(Zres);
    
    Z_res_mean = Zres - mean(Zres); 
    %scatter3(X,Y,Z_res_mean);
    assignin('base','zIdeals', Zideal);
    assignin('base','raw_residuals', Zres);
    assignin('base','residuals_minus_mean', Z_res_mean);
   


% We want our output residuals to be in mm, multiply by 10
answer = Z_res_mean * 10;

assignin('base','spreadsheet_residuals', answer);
    
%     figure
%     scatter3(X,Y,Zideal); hold on;
%     scatter3(X,Y,ZFaro);        
%     legend('ideal','Faro')
%     figure
%     scatter3(X,Y,Zres)


    % we ignore the first and last row of the mold when calculating RMS
    % as they aren't part of the final panels shape (and those rows are
    % broken in the current mold)
    
    Z_res_adj = Z_res_mean(1:16);
    Z_res_adj(5) = [];
    Z_res_adj(13) = [];
    assignin('base','rms_residuals', Z_res_adj);

    % this RMS is in cm, adjust to microns
    rmse = 10000 * rms(Z_res_adj);
    
    
    disp("RMSE = " + rmse);
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
