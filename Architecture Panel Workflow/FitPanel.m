function [fitresult, gof] = FitPanel(coef,measuredPointCloud)
% This function takes a panel point cloud and the ideal coefficients and
% fits it with those coefficeints, for all 4 90 deg orientations to find
% the ideal surface
%% Create Fit Type string
% fitstring = ['a + b*(x-c) + d*(y-e) +', num2str(coef(4)),'*(x)^2 + ',...
%     num2str(coef(5)),'*(x)*(y)+',num2str(coef(6)),'*(y)^2+',...
%     num2str(coef(7)),'*(x)^3+',num2str(coef(8)),'*(x)^2*(y)+',...
%     num2str(coef(9)),'*(x)*(y)^2+',num2str(coef(10)),'*(y)^3'];

fitstring = ['a + b*(x) + d*(y) +', num2str(coef(4)),'*(x-c)^2 + ',...
    num2str(coef(5)),'*(x-c)*(y-e)+',num2str(coef(6)),'*(y-e)^2+',...
    num2str(coef(7)),'*(x-c)^3+',num2str(coef(8)),'*(x-c)^2*(y-e)+',...
    num2str(coef(9)),'*(x-c)*(y-e)^2+',num2str(coef(10)),'*(y-e)^3'];


%% Fit: 'untitled fit 1'.
i = 1;
figure( 'Name', 'Point Cloud to Ideal Equation' );

bestPointCloud = measuredPointCloud;
bestRMS = inf;

for theta = 0:pi/2:3*pi/2
    
 
    A = [cos(theta) sin(theta) 0 0; ...
    -sin(theta) cos(theta) 0 0; ...
    0 0 1 0; ...
    0 0 0 1];
    tform = affine3d(A);
    
    pointcloudtemp = pctransform(measuredPointCloud,tform);
    faroX = pointcloudtemp.Location(:,1);
    faroY = pointcloudtemp.Location(:,2);
    faroZ = pointcloudtemp.Location(:,3);
    [xData, yData, zData] = prepareSurfaceData( faroX, faroY, faroZ );

    % Set up fittype and options.
    ft = fittype(fitstring, 'independent', {'x', 'y'}, 'dependent', 'z' );
    
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [0 0 0 0 0];

    % Fit model to data.
    [fitresult{i}, gof(i) output{i}] = fit( [xData, yData], zData, ft, opts );
    
    % if RMS is lower than current best cloud transformation, make this
    % transformation new best cloud
    if gof(i).rmse < bestRMS
        bestPointCloud = pointcloudtemp;
        bestRMS = gof(i).rmse;
    end 
    
     assignin('base','bestRMS', bestRMS);
    
    
    % Plot fit with data.
    subplot(2,2,i)
    h = plot( fitresult{i}, [xData, yData], zData );
    legend( h, 'untitled fit 1', 'faroZ vs. faroX, faroY', 'Location', 'NorthEast', 'Interpreter', 'none' );
    title([num2str(rad2deg(theta)),'deg ','RMS: ',num2str(gof(i).rmse.*1000),'mm'])
    % Label axes
    xlabel( 'faroX', 'Interpreter', 'none' );
    ylabel( 'faroY', 'Interpreter', 'none' );
    zlabel( 'faroZ', 'Interpreter', 'none' );
    grid on
    view( -20.6, 40.9 );
    i = i+1;
end

     f2 = figure('Name','Measured Data');

     ft = fittype(fitstring, 'independent', {'x', 'y'}, 'dependent', 'z' );
   %  create fit string with free variables 
    freeFitString = ['p1 + p2*(x) + p3*(y) + p4 *(x)^2 + '...
    'p5*(x)*(y) + p6*(y)^2 + '...
    'p7*(x)^3 + p8*(x)^2*(y) + '...
    'p9*(x)*(y)^2 + p10*(y)^3'];

    freeX = bestPointCloud.Location(:,1);
    freeY = bestPointCloud.Location(:,2);
    freeZ = bestPointCloud.Location(:,3);
    [xData, yData, zData] = prepareSurfaceData( freeX, freeY, freeZ );
    
    freeFitType = fittype(freeFitString, 'independent', {'x', 'y'}, 'dependent', 'z' );

    
    freeOpts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    freeOpts.Display = 'Off';
    freeOpts.StartPoint = [0 0 0 0 0 0 0 0 0 0];
    [freeFitResult, freeGof, freeOutput] = fit( [xData, yData], zData, freeFitType, freeOpts );
    freeCoeffValues = coeffvalues(freeFitResult);
    assignin('base',  'freeCoeffValues', freeCoeffValues);
    assignin('base','bestFitPointCloud', bestPointCloud);
    assignin('base', 'freeFitResult', freeFitResult);
    display(freeFitResult);
    display(freeGof);
    display(freeOutput);
   
    h = plot( freeFitResult, [xData, yData], zData );
    legend( h, 'free fit', 'faroZ vs. faroX, faroY', 'Location', 'NorthEast', 'Interpreter', 'none' );
    %title([num2str(rad2deg(theta)),'deg ','RMS: ',num2str(gof(i).rmse.*1000),'mm'])
    % Label axes
    xlabel( 'faroX', 'Interpreter', 'none' );
    ylabel( 'faroY', 'Interpreter', 'none' );
    zlabel( 'faroZ', 'Interpreter', 'none' );
    grid on
    view( -20.6, 40.9 );
    
end



