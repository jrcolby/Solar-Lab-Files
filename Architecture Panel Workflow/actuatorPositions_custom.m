function [Z_res_adjusted] = actuatorPositions_custom(R,X,Y,ZFaro)
    %This function takes in a panel number from the spreadsheet of
    %architecture panel coefficients, and the XY locations of the actuators
    %on the mold, and returns the actuator heights

    % Subtract coordinates of center tile (21) to align shape with origin
    
%     X = X-X(21);
%     Y = Y-Y(21);
%     ZFaro = ZFaro-ZFaro(21);

    

    
    % this formula is unused as first two coefficients are just tip/tilt
    %f = coef(1)+coef(2)*x+fsurf(f, [-25 ,25]);coef(3)*y+coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;

    % Faro arm X Y and Z are in mm, but panel equation is in centimeters,
    % adjust accordingly by dividing mm by 10
    X_centimeters = X / 10;
    Y_centimeters = Y / 10;
    Z_centimeters = ZFaro / 10;
   
    
    % get Z heights of each actuator for equation
    Zideal = (X.^2+Y.^2)/(2*R);
    
    % residuals are difference between equation and actual measurements
    Zres = Zideal-ZFaro;
    
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
