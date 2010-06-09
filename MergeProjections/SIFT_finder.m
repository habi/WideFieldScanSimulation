%% SIFT-Test
% Testing SIFT-algorithm from http://www.vlfeat.org/
clc;clear all;close all

%% Load Files
% for i=100:250:3500
%     disp(['Working on projection ' num2str(i) ])
%     disp('Reading Files')
%     Ia = double(imread(['R:\SLS\2010b\R108C04Aa_B1_s1_\tif\R108C04Aa_B1_s1_' sprintf('%04d',i) '.tif']));
%     Ib = double(imread(['R:\SLS\2010b\R108C04Aa_B1_s2_\tif\R108C04Aa_B1_s2_' sprintf('%04d',i) '.tif']));
%     DarkA = double(imread('R:\SLS\2010b\R108C04Aa_B1_s1_\tif\R108C04Aa_B1_s1_0004.tif'));
%     DarkB = double(imread('R:\SLS\2010b\R108C04Aa_B1_s2_\tif\R108C04Aa_B1_s2_0004.tif'));
%     FlatA = double(imread('R:\SLS\2010b\R108C04Aa_B1_s1_\tif\R108C04Aa_B1_s1_0040.tif'));
%     FlatB = double(imread('R:\SLS\2010b\R108C04Aa_B1_s2_\tif\R108C04Aa_B1_s2_0040.tif'));
%     Ia = mat2gray(log(FlatA-DarkA)-log(Ia-DarkA));
%     Ib = mat2gray(log(FlatB-DarkB)-log(Ib-DarkB));

    Ia = imread('u:\Gruppe_Schittny\images\Sebastien\FotosR108C21C\R108C21C-043.tif');
    Ib = imread('s:\SLS\2008c\mrg\R108C21Cc_mrg\rec_8bit\R108C21Cc_mrg0774.rec.8bit.tif');
    
    %% Prepare Images for SIFT
    Ia = single(Ia);
    Ib = single(Ib);

    %Crop Images
    %CropTo = 444;
    %Ia = Ia(:,end-CropTo+1:end);
    %Ib = Ib(:,1:CropTo);

    %% Calculate SIFT
    disp('Calculating SIFT')
    [fa, da] = vl_sift(Ia);
    [fb, db] = vl_sift(Ib);
    [matches scores] = vl_ubcmatch(da,db,3);
    [drop, perm] = sort(scores, 'descend');
    matches = matches(:,perm);
    scores  = scores(perm);

    %% Prepare Figure
    shift = 25;

    %Calculate stuff for figure
    xa = fa(1,matches(1,:));
    cutlinea=round(mean(xa));
    xb = fb(1,matches(2,:));
    cutlineb=round(mean(xb));
    if isnan(cutlinea) | isnan(cutlineb)
        disp(['!!!! no cutline found for projection ' num2str(i) '!!!!'])
        cutlinea=1;
        cutlineb=cutlinea;
    end
    xb = xb + size(Ia,2) + shift;
    ya = fa(2,matches(1,:));
    yb = fb(2,matches(2,:));
    fb(1,:) = fb(1,:) + size(Ia,2) + shift;
    MergedProjection=([ Ia(:,1:cutlinea) Ib(:,cutlineb:end) ]);

    figure(i)
        subplot(121)
            imshow([ Ia zeros(size(Ia,1),shift) Ib ],[]);
            hold on;
            h = line([xa; xb], [ya; yb]);
            set(h,'linewidth', 2, 'color', 'b');
            vl_plotframe(fa(:,matches(1,:)));
            vl_plotframe(fb(:,matches(2,:)));
        subplot(122)
            imshow(MergedProjection,[])
    disp('---')
% end