function [skin_img, backg_img, outlier_img] = color_segment(img_file_name)

imgdir  = 'classifier/';
skindir = 'classifier/skin-masks/';
bakdir  = 'classifier/backg-masks/';
%imgdir  = '/usr/class/cs223b/WWW/classifier/';
%skindir = '/usr/class/cs223b/WWW/classifier/skin-masks/';
%bakdir  = '/usr/class/cs223b/WWW/classifier/backg-masks/';


skin = [41 45 47 49 51 60 62 64 66 68];
n = size(skin);
skin_rgb_data = [];
for i = 1 : n(2)
  
    img = double(imread([imgdir 'P10100' num2str(skin(i)) '_s.jpg']));
    r = img(:,:,1); g = img(:,:,2); b = img(:,:,3);
    skin_mask = double(imread([skindir 'M00' num2str(skin(i)) '.tif']));
    skin_inds = find(skin_mask>0);
    skin_rgb_data = [skin_rgb_data; r(skin_inds),g(skin_inds),b(skin_inds)];

end


skin_hsv_data = rgb2hsv(skin_rgb_data); 
skin_hsv2_data = [cos(skin_hsv_data(:,1)).*skin_hsv_data(:,2), sin(skin_hsv_data(:,1)).*skin_hsv_data(:,2),skin_hsv_data(:,3)]; 


skin_mean=mean(skin_rgb_data);
skin_cov=cov(skin_rgb_data);

bak = [32 34 36 38 40 54 56 58];
n = size(bak);
bak_rgb_data = [];
for i = 1 : n(2)
    
    img = double(imread([imgdir 'P10100' num2str(bak(i)) '_s.jpg']));
    r = img(:,:,1); g = img(:,:,2); b = img(:,:,3);    
    bak_mask = double(imread([bakdir 'M00' num2str(bak(i)) '.tif']));
    bak_inds = find(bak_mask>0);
    bak_rgb_data = [bak_rgb_data; r(bak_inds),g(bak_inds),b(bak_inds)];

end

bak_hsv_data = rgb2hsv(bak_rgb_data); 
bak_hsv2_data = [cos(bak_hsv_data(:,1)).*bak_hsv_data(:,2), sin(bak_hsv_data(:,1)).*bak_hsv_data(:,2),bak_hsv_data(:,3)]; 

bak_mean = mean(bak_rgb_data);
bak_cov = cov(bak_rgb_data);

%img = imread([imgdir 'P1010036_s.jpg']);
%img = imread([imgdir 'class-1.jpg']);
input = imread([imgdir 'class-2.jpg']);

%img = imread(img_file_name);
test = double(input);
r = test(:,:,1); g = test(:,:,2); b = test(:,:,3);
test_rgb_data = [r(:), g(:), b(:)];

P1 = gaussdensity(test_rgb_data, skin_mean, skin_cov);
P2 = gaussdensity(test_rgb_data, bak_mean, bak_cov);

[rows cols dummmy] = size(test);
L1 = reshape(P1,rows,cols);
L2 = reshape(P2,rows,cols);
L3 = ones(rows,cols)/256;

S=L1+L2+L3;

% as prior =1/3 therefore required probabilty is same as normalized posterier...

skin_img = L1./S; backg_img = L2./S; outlier_img = L3./S; 

figure(1); imagesc(input); colormap(gray); axis image; title('input image');
figure(2); imagesc(skin_img); colormap(gray); axis image; title('skin layer');
figure(3); imagesc(backg_img); colormap(gray); axis image; title('background layer');
figure(4); imagesc(outlier_img); colormap(gray); axis image; title('outlier layer');

