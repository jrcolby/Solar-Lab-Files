tile_d = 3.5;
col_d = 7.5;

B2x = -7*tile_d;
B2y = 7.5*tile_d;
rowBx = B2x:col_d:B2x+col_d*7;
rowBy = B2y*ones(1,8);

tilepointsX = [];
tilepointsY = [];
tilepointsX(1,:) = rowBx;
tilepointsY(1,:) = rowBy;
for i = 2:9
    
    if mod(i,2) == 0
        tilepointsX(i,:) = rowBx+tile_d;
        tilepointsY(i,:) = rowBy-(i-1)*col_d;
    else
        tilepointsX(i,:) = rowBx;
        tilepointsY(i,:) = rowBy-(i-1)*col_d;
    end
  

end
load("archpan1001.mat");
panelnum = 60;
% get constants from spreadsheet of panel equation information
coef = archpan1001((panelnum+1),2:11);
syms('x','y')
panelfunction = coef(4)*x^2+coef(5)*x*y+coef(6)*y^2+coef(7)*x^3+coef(8)*x^2*y+coef(9)*x*y^2+coef(10)*y^3;

% make surface plot of panel (comment line below out to stop displaying
fsurf(panelfunction, [-25 ,25]);

% turn equation f into matlab function
panelfunction = matlabFunction(panelfunction);

Zideal = panelfunction(tilepointsX(:),tilepointsY(:));
scatter(tilepointsX(:),tilepointsY(:));

for i = 1:length(Zideal)
    hold on
    text(tilepointsX(:),tilepointsY(:),num2str(round((Zideal-max(Zideal))*10,1)),'FontSize',14)
end
    
