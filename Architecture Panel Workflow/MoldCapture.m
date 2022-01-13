clc; clear all; close all;
load('MoldMasks.mat')
load('StereoCalib_01_11_2022_mold.mat')
vid1 = webcam(1);
vid1.Resolution = '3264x2448';
vid1.ExposureMode = 'manual';
vid1.Exposure = -3;
vid1.Contrast = 64;
vid1.Gamma = 72;
vid2 = webcam(2);
vid2.Resolution = '3264x2448';
vid2.ExposureMode = 'manual';
vid2.Exposure = -2;
vid2.Contrast = 64;
vid2.Gamma = 72;
numaverages = 5;
panelNumber = 66;
iter = 1;
while 1
    tic
    for i = 1:numaverages
        Im1(:,:,i) = rgb2gray(snapshot(vid1));
        Im2(:,:,i) = rgb2gray(snapshot(vid2));
    end
    Im1  = sum(Im1,3)/numaverages;
    Im2  = sum(Im2,3)/numaverages;
    

    %A = Im1.*mask1; B = Im2.*mask2; 
    [centroid1,radii1] = imfindcircles(Im1,[15 32],'ObjectPolarity','dark','Sensitivity',0.86);
    [centroid2,radii2] = imfindcircles(Im2,[15 32],'ObjectPolarity','dark','Sensitivity',0.86);
    centroid1 = centroid1(1:21,:);
    centroid2 = centroid2(1:21,:);

%     A(A<180) = 0;
%     A(A>=180) = 255;
%     CC = bwconncomp(A);
%     for i = 1:CC.NumObjects
%         list = CC.PixelIdxList{i};
%         s(i) = length(list);
%         if s(i) < 3000 || s(i) > 20000
%             s(i) = 0;
%             [rows,cols] = ind2sub([2448,3264],list);
%             A(rows,cols) = 0;
%         end
% 
%     end
%     CC = bwconncomp(A);
%     centroid1_hex = regionprops(CC,'Centroid');
%     centroid1_hex = cat(1,centroid1_hex.Centroid);
% %     figure;
% %     imshow(A)
% %     hold on
% %     plot(centroid1(:,1),centroid1(:,2),'b*')
% %     hold off
% 
%     B(B<75) = 0;
%     B(B>=75) = 255;
%     CC = bwconncomp(B);
%     for i = 1:CC.NumObjects
%         list = CC.PixelIdxList{i};
%         s(i) = length(list);
%         if s(i) < 3000 || s(i) > 20000
%             s(i) = 0;
%             [rows,cols] = ind2sub([2448,3264],list);
%             B(rows,cols) = 0;
%         end
% 
%     end
%     CC = bwconncomp(B);
%     centroid2_hex = regionprops(CC,'Centroid');
%     centroid2_hex = cat(1,centroid2_hex.Centroid);
%     
    [m,idx1] = sort(centroid1(:,1));
    centroid1 = centroid1(idx1,:);
    [m,idx2] = sort(centroid2(:,1));
    centroid2 = centroid2(idx2,:);
    
    center1 = centroid1(9,:); center2 = centroid2(9,:);
    centroid1(9,:) = [];    centroid2(9,:) = [];

    I_1 = clusterdata(centroid1(:,1),5);
    I_2 = clusterdata(centroid2(:,1),5);
%     [m,idx1] = sort(I_1);
%     [m,idx2] = sort(I_2);

    centroid1_Xsorted = centroid1;
    centroid2_Xsorted = centroid2;
    for i = 1:5
       columnpointsY = centroid1_Xsorted((i-1)*4+1:(i-1)*4+1+3,2);
       [m,idx1] = sort(columnpointsY);
       idx1 = idx1+(i-1)*4;
       centroid1_sorted((i-1)*4+1:(i-1)*4+1+3,:) = centroid1_Xsorted(idx1,:);
       
      columnpointsY = centroid2_Xsorted((i-1)*4+1:(i-1)*4+1+3,2);
       [m,idx2] = sort(columnpointsY);
       idx2 = idx2+(i-1)*4;
       centroid2_sorted((i-1)*4+1:(i-1)*4+1+3,:) = centroid2_Xsorted(idx2,:);
        
    end
    
    centroidsall1 = [centroid1_sorted; center1];
    centroidsall2 = [centroid2_sorted; center2];
    [worldPoint, reprojError] = triangulate(centroidsall1,centroidsall2,stereoParams);

    ptc = pointCloud(-worldPoint);
    Xc = -ptc.Location(:,1);
    Yc = ptc.Location(:,2);
    Zc = ptc.Location(:,3);
    Xc = Xc-Xc(end);
    Yc = Yc-Yc(end);
    Zc = Zc-Zc(end);
    ptc = pointCloud([Xc Yc Zc]);
    

    %Create Plane
    xp = -250:250;
    yp = xp;
    [Xp,Yp] = meshgrid(xp,yp);
    Zp = zeros(length(xp),length(yp));
    Xp = Xp(:);Yp = Yp(:); Zp = Zp(:);
    ptcplane = pointCloud([Xp Yp Zp]);
    if iter == 1
        tform = pcregistericp(ptc,ptcplane);
    end
    ptc = pctransform(ptc,tform); %transform point cloud
    Xc = ptc.Location(:,1);
    Yc = ptc.Location(:,2);
    Zc = ptc.Location(:,3);
    Xc = Xc-Xc(end);
    Yc = Yc-Yc(end);
    Zc = Zc-Zc(end);
    ptc = pointCloud([Xc Yc Zc]);

    if iter == 1
        Xaxis_X = Xc([16,8]);
        Xaxis_Y = Yc([16,8]);
        theta = -atan((Xaxis_Y(2)-Xaxis_Y(1))/(Xaxis_X(2)-Xaxis_X(1)));


        A = [cos(theta) sin(theta) 0 0; ...
         -sin(theta) cos(theta) 0 0; ...
         0 0 1 0; ...
         0 0 0 1];
        tform_axis = affine3d(A);
    end
    
    ptc = pctransform(ptc,tform_axis);
    Xc = ptc.Location(:,1);
    Yc = ptc.Location(:,2);
    Zc = ptc.Location(:,3);

    Zresiduals = 10*actuatorPositions(panelNumber,Xc,Yc,Zc);
    Zresiduals = Zresiduals-max(Zresiduals);
    
    pcshow(ptc,'MarkerSize',500); drawnow; axis square; hold on
    quiver3(Xc,Yc,Zc,zeros(21,1),zeros(21,1),Zresiduals)
    for i = 1:21
        text(Xc(i),Yc(i),Zc(i),num2str(round(Zresiduals(i),1)),'Color','white','FontSize',12)
    end
    text(Xc(4),Yc(4),Zc(4),'B2','HorizontalAlignment','right','Color','white','FontSize',14)
    
    ZforRMS = Zresiduals([1:7,9:15]);
    title(['RMS: ' num2str(rms(ZforRMS-mean(ZforRMS))) 'mm'],'Color','white')
    hold off
    toc
    iter = iter+1;
end
