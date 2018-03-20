%% Clear workspace 
close all;
clear all;
clc;
%% Read Images
I1 = imread('LostBook.JPG');
figure;
imshow(I1);
title('Object');
I2 = imread('ClutteredScene3.JPG');    
figure;
imshow(I2);
title('Scene');


% detect surf features
  points1 = detectSURFFeatures(rgb2gray(I1));
  points2 = detectSURFFeatures(rgb2gray(I2));
  
 % extract features
   [feats1, validpts1] = extractFeatures(rgb2gray(I1), points1);
   [feats2, validpts2] = extractFeatures(rgb2gray(I2), points2);
 
   % display 100 strongest features IN IMAGE I1
    figure;
    imshow(I1);hold on;
    plot(validpts1.selectStrongest(100), 'showOrientation', true);
    title('Detected Features');
    
  % match Features
    index_pair = matchFeatures(feats1,feats2,'Prenormalized', true);
    
    matchPts1 = validpts1(index_pair(:,1));
    matchPts2 = validpts2(index_pair(:,2));figure;
    showMatchedFeatures(I1, I2, matchPts1, matchPts2, 'montage');
    title('Initial Matches');
 
 % location of object in image
    boxPolygon = [1, 1;...                           % top-left
             size(I1, 2), 1;...                  % top-right
             size(I1, 2), size(I1, 1);...        % bottom-right
             1, size(I1, 1);...                  % bottom-left
             1, 1];                               % top-left again to close the polygon
    
% Remove outliers while estimating geometric transform using RANSAC
[tform, inlieroints1, inlierPoints2] = estimateGeometricTransform(matchPts1,matchPts2,'affine');
figure; 
showMatchedFeatures(I1,I2,inlieroints1,inlierPoints2,'montage');
title('Filtered Matches');
     
% Use estimated transfor to locate object 
newBoxPolygon = transformPointsForward(tform, boxPolygon);

% Overlat the detected location of object in Image I2
figure; 
imshow(I2);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'g','LineWidth',5);
title('Detected object');

    
  