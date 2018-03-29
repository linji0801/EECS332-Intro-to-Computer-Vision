function [q] = guass(img_name)
img = img_name;
p = gaussdensity(img);
q = em(img);
end

function p = gaussdensity(img_name)
img = imread(img_name,'bmp');
test = double(img);
r = test(:,:,1); g = test(:,:,2); b = test(:,:,3);
test_rgb_data = [r(:), g(:), b(:)];

mn = mean(test_rgb_data);
cv = cov(test_rgb_data);
[rows, cols] = size(img);

if cols == 3
    dmn = [img(:,1)-mn(1) img(:,2)-mn(2) img(:,3)-mn(3)];
elseif cols == 2
    dmn = [img(:,1)-mn(1) img(:,2)-mn(2)];
end

coeff = 1/((2*pi)^(3/2) * sqrt(det(cv)));

mexp1 = dmn * inv(cv);
mexp2 = mexp1 .* dmn;
msum = sum(mexp2,2);

p = coeff * exp(-0.5 * msum);
end


function em(img_file_name)

k=5;

img = imread(img_file_name);
%img = (imread('classifier/P1010036_s.jpg'));
%img = (imread('classifier/P1010036_s.jpg'));
%img = imread('classifier/class-1.jpg');

test = double(img);
r = test(:,:,1); g = test(:,:,2); b = test(:,:,3);
test_rgb_data = [r(:), g(:), b(:)];

MN = mean(test_rgb_data);
CV = cov(test_rgb_data);
    
for i = 1 : k
    mn(i,:) = MN + rand(1,3);
end

cv = CV/k;

iter = 10;
for it = 1 : iter
    
    for i = 1 : k
        p(:,i) = gsaussdensity(test_rgb_data, mn(i,:), cv);
    end

    [rows,cols,dummy]=size(test);
    
    S = p(:,1);
    for i = 2 : k
        S = S + p(:,i);
    end

    for i = 1 : k
        p(:,i) = p(:,i)./S;  
    end

    % pos = p

    for i = 1 : k
        mn(i,:) =  [ sum(p(:,i).*test_rgb_data(:,1)), sum(p(:,i).*test_rgb_data(:,2)), sum(p(:,i).*test_rgb_data(:,3))]/sum(p(:,i));       
    end
        
    for i = 1 : k
        L(:,:,i) = reshape(p(:,i),rows,cols);    
    end

    %for i = 1 : k
      %  subplot(k,1,i); imagesc(L(:,:,i)); colormap(gray); axis image;
    %end
    
    it;
    
end

for i = 1 : k
    figure(i); imagesc(L(:,:,i)); colormap(gray); axis image;
end

figure(k+1); imagesc(img); axis image;
end



