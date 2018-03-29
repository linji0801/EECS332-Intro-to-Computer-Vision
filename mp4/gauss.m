function gauss(img_in)

k=5;

img = imread(img_in);

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
        p(:,i) = gaussdensity(test_rgb_data, mn(i,:), cv);
    end

    [rows,cols,dummy]=size(test);
    
    S = p(:,1);
    for i = 2 : k
        S = S + p(:,i);
    end

    for i = 1 : k
        p(:,i) = p(:,i)./S;  
    end


    for i = 1 : k
        mn(i,:) =  [ sum(p(:,i).*test_rgb_data(:,1)), sum(p(:,i).*test_rgb_data(:,2)), sum(p(:,i).*test_rgb_data(:,3))]/sum(p(:,i));       
    end
        
    for i = 1 : k
        L(:,:,i) = reshape(p(:,i),rows,cols);    
    end
    
    it;
    
end

for i = 1 : k
    figure(i); 
    imshow(L(:,:,i));colormap(gray); axis image;
end

%figure(k+1);% imshow(img); axis image;


