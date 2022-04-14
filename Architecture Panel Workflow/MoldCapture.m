clc; clear all; close all;
load('MoldMasks.mat')
load('StereoCalib_01_11_2022_mold.mat')

%Connect to Webcams
list = webcamlist;
vid1 = webcam(2);
vid1.Resolution = '3264x2448';
vid1.ExposureMode = 'manual';
vid1.Exposure = -3;
vid1.Contrast = 64;
vid1.Gamma = 72;
vid2 = webcam(3);
vid2.Resolution = '3264x2448';
vid2.ExposureMode = 'manual';
vid2.Exposure = -2;
vid2.Contrast = 64;
vid2.Gamma = 72;
numaverages = 20; %Number of images to average over for each measurement
panelNumber = 61; %Panel number being formed
iter = 1;

while 1
    tic
    %Image Capture Loop
    for i = 1:numaverages
        Im1(:,:,i) = rgb2gray(snapshot(vid1));
        Im2(:,:,i) = rgb2gray(snapshot(vid2));
    end
    Im1  = sum(Im1,3)/numaverages;
    Im2  = sum(Im2,3)/numaverages;
    

    %A = Im1.*mask1; B = Im2.*mask2; 
    %Find Circles in both images
    [centroid1,radii1] = imfindcircles(Im1,[15 32],'ObjectPolarity','dark','Sensitivity',0.87);
    [centroid2,radii2] = imfindcircles(Im2,[15 32],'ObjectPolarity','dark','Sensitivity',0.87);
    centroid1 = centroid1(1:21,:);
    centroid2 = centroid2(1:21,:);

    %Sort circles so that they are in the same order in both images
    [m,idx1] = sort(centroid1(:,1));
    centroid1 = centroid1(idx1,:);
    [m,idx2] = sort(centroid2(:,1));
    centroid2 = centroid2(idx2,:);
    
    %Remove Center point from list of actuators
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
    %Return center point to list of points
    centroidsall1 = [centroid1_sorted; center1];
    centroidsall2 = [centroid2_sorted; center2];
    %Triangulate matched points
    [worldPoint, reprojError] = triangulate(centroidsall1,centroidsall2,stereoParams);
    
    %Create Point Cloud
    ptc = pointCloud(-worldPoint);
    Xc = -ptc.Location(:,1);
    Yc = ptc.Location(:,2);
    Zc = ptc.Location(:,3);
    %Center point cloud on origin using center point
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
    %register the point cloud with a reference plane on the first iteration
    if iter == 1
        tform_plane = pcregistericp(ptc,ptcplane);
    end
    ptc = pctransform(ptc,tform_plane); %transform point cloud to reference plane
    Xc = ptc.Location(:,1);
    Yc = ptc.Location(:,2);
    Zc = ptc.Location(:,3);
    Xc = Xc-Xc(end);
    Yc = Yc-Yc(end);
    Zc = Zc-Zc(end);
    ptc = pointCloud([Xc Yc Zc]);
    
    %On first iteration, define X and Y axis using mold points
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
    %Transform point cloud to align x and y axis
    ptciteration{iter} = pctransform(ptc,tform_axis);
    Xc = ptc.Location(:,1);
    Yc = ptc.Location(:,2);
    Zc = ptc.Location(:,3);
    
    %Calculate residuals from panel coefficient data
    Zresiduals = 10*actuatorPositions(panelNumber,Xc,Yc,Zc);
    %Subtract the mx residual so that all acuators need to be pulled down
    Zresiduals = Zresiduals-max(Zresiduals);
    
    %Plotting for user feedback
    pcshow(ptc,'MarkerSize',500); drawnow; axis square; hold on
    quiver3(Xc,Yc,Zc,zeros(21,1),zeros(21,1),Zresiduals)
    for i = 1:20
        text(Xc(i),Yc(i),Zc(i),num2str(round(Zresiduals(i),1)),'HorizontalAlignment','left','Color','white','FontSize',12);
    end
    text(Xc(4),Yc(4),Zc(4),'B2','HorizontalAlignment','right','Color','white','FontSize',14)
    text(Xc(1),Yc(1),Zc(1),'B8','HorizontalAlignment','right','Color','white','FontSize',14)

    ZforRMS = Zresiduals([1:7,9:15]);
    rmsiteration(iter) = rms(ZforRMS-mean(ZforRMS));
    title(['RMS: ' num2str(rms(ZforRMS-mean(ZforRMS))) 'mm'],'Color','white')
    hold off
    toc
    iter = iter+1;
    strng = input('Press Enter to remeasure, type *s* to save pointclouds and iterations rms','s');
    if strcmp(strng,'s')
        break
    else 
        continue
    end
end

if strcmp(strng,'s')
    save(['Panel',num2str(panelNumber),'_Mold'],'ptciteration','rmsiteration','tform_plane')
end
