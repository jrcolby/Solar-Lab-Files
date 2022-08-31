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
vid2 = webcam(1);
vid2.Resolution = '3264x2448';
vid2.ExposureMode = 'manual';
vid2.Exposure = -2;
vid2.Contrast = 64;
vid2.Gamma = 72;
numaverages = 20; %Number of images to average over for each measurement
panelNumber = 60; %Panel number being formed
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
    load('MoldMasks.mat')
    Im1 = Im1.*mask2;
    Im2 = Im2.*mask1;
    f = figure;
     imagesc(Im1); [x,y] = ginput(1);
    roi = images.roi.Circle('Center',[x,y],'Radius',50);
    centermask1 = createMask(roi,Im1);
    imagesc(Im2); [x,y] = ginput(1);
    roi = images.roi.Circle('Center',[x,y],'Radius',50);
    centermask2 = createMask(roi,Im2);
    close(f)
    Im1_centermasked = Im1.*~centermask1; 
    Im2_centermasked = Im2.*~centermask2; 
    %Find Circles in both images
    Im1_centermasked = Im1.*~centermask1; 
    Im2_centermasked = Im2.*~centermask2; 
    [centroid1,radii1] = imfindcircles(Im1_centermasked,[18 35],'ObjectPolarity','dark','Sensitivity',0.89);
    [centroid2,radii2] = imfindcircles(Im2_centermasked,[18 35],'ObjectPolarity','dark','Sensitivity',0.9);
    idx = [];
    

    mask1 = zeros(size(Im1));
    for i = 1:size(centroid1,1)
        roi = images.roi.Circle('Center',centroid1(i,:),'Radius',radii1(i));
        masktemp = createMask(roi,Im1);
        mask1 = mask1+masktemp;
     
    end
    mask2 = zeros(size(Im1));
    for i = 1:size(centroid2,1)
        roi = images.roi.Circle('Center',centroid2(i,:),'Radius',radii2(i));
        masktemp = createMask(roi,Im2);
        mask2 = mask2+masktemp;
    end
    
    centroid1 = undistortPoints(centroid1,stereoParams.CameraParameters1);
    centroid2 = undistortPoints(centroid2,stereoParams.CameraParameters2);
    [imagePoints] = detectCircleGridPoints(uint8(255*mask1),uint8(255*mask2),[8,9],PatternType="asymmetric",circleColor='white');
    [worldPoints, reprojError] = triangulate(imagePoints(:,:,1,1),imagePoints(:,:,1,2),stereoParams);

    Im1_centeronly = Im1.*centermask1;
    Im2_centeronly = Im2.*centermask2;

    [centroid1center,radii1] = imfindcircles(Im1_centeronly,[15 30],'ObjectPolarity','dark','Sensitivity',0.91);
    [centroid2center,radii2] = imfindcircles(Im2_centeronly,[15 30],'ObjectPolarity','dark','Sensitivity',0.91);


    centroid1center = undistortPoints(centroid1center,stereoParams.CameraParameters1);
    centroid2center = undistortPoints(centroid2center,stereoParams.CameraParameters2);
        
    [worldPointCenter, reprojError] = triangulate(centroid1center,centroid2center,stereoParams);

    %Create Point Cloud
    worldPoints = [worldPoints;worldPointCenter];
    ptc = pointCloud(-worldPoints+worldPointCenter);
    Xc = -ptc.Location(:,1);
    Yc = ptc.Location(:,2);
    Zc = ptc.Location(:,3);
    %Center point cloud on origin using center point
    Xc = Xc-Xc(end);
    Yc = Yc-Yc(end);
    Zc = Zc-Zc(end);
    ptc = pointCloud([Xc Yc Zc]);
    

    %Create Plane
    xp = -300:10:300;
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
        Xaxis_X = Xc([end-8,end-1]);
        Xaxis_Y = Yc([end-8,end-1]);
        theta = -atan((Xaxis_Y(2)-Xaxis_Y(1))/(Xaxis_X(2)-Xaxis_X(1)));
        A = [cos(theta) sin(theta) 0 0; ...
         -sin(theta) cos(theta) 0 0; ...
         0 0 1 0; ...
         0 0 0 1];
        tform_axis = affine3d(A);
        
    end
    %Transform point cloud to align x and y axis
    ptciteration{iter} = pctransform(ptc,tform_axis);
    Xc = ptciteration{iter}.Location(:,1);
    Yc = ptciteration{iter}.Location(:,2);
    Zc = ptciteration{iter}.Location(:,3);
    
    %Calculate residuals from panel coefficient data
    %Zresiduals = 10*actuatorPositions(panelNumber,Xc,Yc,Zc);
    [Zresiduals] = actuatorPositions_custom(10000,Xc,Yc,Zc);
    %Subtract the mx residual so that all acuators need to be pulled down
    Zresiduals = Zresiduals-max(Zresiduals);
    
    %Plotting for user feedback
    pcshow(ptciteration{iter},'MarkerSize',500); drawnow; axis square; hold on
    quiver3(Xc,Yc,Zc,zeros(73,1),zeros(73,1),Zresiduals/5)
    for i = 1:length(Xc)
        text(Xc(i),Yc(i),Zc(i),num2str(round(Zresiduals(i),1)),'HorizontalAlignment','left','Color','white','FontSize',12);
    end
    text(Xc(end-1),Yc(end-1),Zc(end-1),'B8','HorizontalAlignment','right','Color','white','FontSize',14)
    text(Xc(end-8),Yc(end-8),Zc(end-8),'B1','HorizontalAlignment','right','Color','white','FontSize',14)
    view(0,90)
    xlabel('X (mm)'); ylabel('Y (mm)');
%     ZforRMS = Zresiduals([1:7,9:15]);
    ZforRMS = Zresiduals;
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
