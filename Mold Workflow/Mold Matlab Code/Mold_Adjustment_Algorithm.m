%XYZ Reader

clc

%Read XYZ data into column vectors
X = I6M2(:,1);  
Y = I6M2(:,2);
Z = I6M2(:,3);

%% Iteration Generator
 
c = 81;                     %center tile number
cornertile = 1;             %corner tile number
R = 4340;                   %radius of curvurture mm
len = 500;                  %side length mm
D = sqrt(2)*len;            %diagonal mm
sag = R - sqrt(R^2-(D/2)^2) %sag mm
f = R/2;                    %focal length mm
a = 1/(4*f);                %'a' coefficient in paraboloid equation

%Calculate tile coordinate to shift equation by 
X_c = X(c);                 %center tile X
Y_c = Y(c);                 %center tile Y
Z_c = Z(c);                 %center tile Z
Z_corner = Z(cornertile);   %corner tile Z
offset = Z_corner - sag;    %initial Z offset for paraboloid

%Calculates residual data (difference between ideal and real Z values)
Z_ideal = zeros(1,length(Z));
Z_res = zeros(1, length(Z));

for i = 1:length(Z)
    Z_ideal(i) = offset + a*(X(i)-X_c)^2 + a*(Y(i)-Y_c)^2;   %Z values for ideal paraboloid
    Z_res(i) = Z_ideal(i) - Z(i);                            %Residual error mm
end

Z_ideal = Z_ideal'; %transpose vectors
Z_res = Z_res';

% Below lines of code are for generating text file for smart drill
% ID = 1:1:length(Z_res);
% ID=ID';
% rot =
% Residuals = cat(2,ID,Z_res,rot);
% writematrix(Residuals,'Residuals.csv')

%Calculate true RMSE by adjusting residuals by the mean of the residuals
Z_res_adj = Z_res - mean(Z_res);            %use this for adjustment residuals (COPY PASTE INTO EXCEL)
rmse = 1e3*rms(Z_res_adj)                   %put in units of microns
Z_ideal_heights = Z_ideal - mean(Z_res);    %adjusted ideal heights (ALSO COPY AND PASTE)

% Visualization Plotting
z = @(x,y) offset - mean(Z_res) + a*(x-X_c)^2 + a*(y-Y_c)^2;
subplot(2,1,1)
xmin = min(X);
xmax = max(X);
ymin = min(Y);
ymax = max(Y);
fsurf(z,[xmin xmax ymin ymax])
hold on
plot3(X,Y,Z_ideal,'k.')
title('Ideal and Measured Point Clouds')
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Z (mm)')
hold on 
plot3(X,Y,Z,'r.')
hold off
legend('Z ideal (surface)','Z ideal (points)','Z measured')
subplot(2,1,2)
plot3(X,Y,Z_res_adj,'k.')
title('Residuals')
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Z (mm)')

1%% Iteration plot
It = [0,1,2,3,4]; %manually input
RMS = [2.939e+03,346,720,229,197,273]; %manually input 
scatter(It,RMS)
xlabel('Iteration')
ylabel('RMS Error (um)')
title('Iteration Number vs RMS Error')
grid on