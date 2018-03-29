function img_out = HistoEqualization123(img_in)
%implement a function for Histogram Equalization, imput of which is the
%input image and output is the tackled image.
Image = rgb2gray(imread(img_in,'bmp'));
[r , c] = size(Image);
n = r * c;
output = uint8(zeros(r , c)); %It has to be int8 
f = zeros(256 , 1); %count the number of pixels in the image with the same intensity
PDF = zeros(256 , 1);%vector for probability density function
CDF = zeros(256 , 1);%vector for cumulative distribution function
Final = zeros(256 , 1);%vector for rounding the final intensity of each pixel

%loop for probability density function
for i = 1 : r
    for j = 1 : c
        value = Image(i , j);
        f(value + 1) = f(value +1) + 1;
        PDF(value + 1) = f(value + 1) / n;
    end
end

%loop for cumulative distribution function
L = 255; %it has to be 255 because the range of the 8-bit image is 0-255
CDF(1) = PDF(1);
for i = 2 : size(PDF)
    CDF(i) = CDF(i-1) + PDF(i);
    Final(i) = round(CDF(i) * L);
end

%output the histogram equalized image
for i = 1 : r
    for j = 1 : c
        output(i,j) = Final(Image(i,j) + 1);
    end
end

%img_out = imshow(output); %The output of HistoEqualization without
                           %Lighting Correcting

%Lighting Correction using linear method & quadratic method
X = ones(256*256,1); %linear data vector
U = ones(256*256,6); %quadratic data vector
Y = zeros(256*256,1); %vector for storing the intensity of image
Z = ones(256*256,1);
k = 1;
for i = 1 : r
    for j = 1 : c
        X(k,1) = i;
        %X(k,2) = j;
        Z(k,1) = j;
        U(k,1) = i*i;
        U(k,2) = i*j;
        U(k,3) = j*j;
        U(k,4) = i;
        U(k,5) = j;
        Y(k,1) = output(i,j);
        k = k + 1;
    end
end

a = (X'*X)^-1 * X' * Y; %parameter vector for fitting plane
b = (U'*U)^-1 * U' * Y; %parameter vector for fitting curve
Y1 = X * a;
Y2 = U * b;
Y_line = (Y + Y1)/2; %compensate for the original intensity in the linear method
Y_quad = (Y + Y2)/2; %compensate for the original intensity in the quadratic method

%output the final image after lighting correction
l = 1;
for i = 1:r
    for j = 1:c
        output(i,j) = Y_quad(l,1);
        l = l + 1;
    end
end

%plot the fitting plane or curve
t = 1:5:300;
[x,y] = meshgrid(t);
%z = griddata(X,Z,Y,x,y);
%z = a(1,1) * x + a(2,1) * y + a(3,1);
z = b(1,1) * x^2 + b(2,1) * x*y + b(3,1) * y^2 + b(4,1) * x + b(5,1) * y + b(6,1);
mesh(x,y,z);
title('fitting curve');
%img_out = imshow(output);
end



