I_orig = double(imread('test.bmp'));%blobs.png moon.tif cameraman.tif liftingbody.png eight.tif
imshow(I_orig,[]), impixelinfo, title('original image');

%----------------------Edge Detection----------------------------------------%
I = edge (I_orig, 'canny', .4);

%figure, imshow(I, []), title('thresholded image'), impixelinfo;

%-------------------------Hough Transform-----------------------------------------%

[M N] = size(I);
r_min = round(-sqrt(M^2 + N^2));
r_min = abs(r_min)+1;
r_max = r_min + round(sqrt(M^2 + N^2));

A = zeros(180+181, r_max);
for x=1:size(I,1)
    for y=1:size(I,2)
        
        if I(x,y) == 1
            for t=0:179
                %t=round(phase(x,y))+181;
                r = x*cos(deg2rad(t)) + y*sin(deg2rad(t));
                r = round(r);
                
                A(t+1,r+r_min) = A(t+1,r+r_min)+1;
            end
        end
    end
end
%figure, imshow(A,[]), impixelinfo, title('A');
filt = fspecial('gaussian', [5, 5], .6);
%figure, imshow (filt, []), impixelinfo
A = conv2(A, filt, 'same');
%figure, imshow(A,[]), impixelinfo, title('A');

% ---------- 1st Peak ---------
max_A = max(max(A));
First_peak=[];
for i=1:size(A,1)
    for j=1:size(A,2)
        if A(i,j) == max_A
            t = i-1;
            r = j-r_min;
            First_peak = [i, j];
        end
    end
end

if t>=45 && t<135
    x=0:max(size(I,1),size(I,2));
    y=round((r-x*cos(deg2rad(t)))/sin(deg2rad(t)));
else
    y=0:max(size(I,1),size(I,2));
    x=round((r-y*sin(deg2rad(t)))/cos(deg2rad(t)));
end

%figure, imshow(I,[]), impixelinfo, title('lines detected');
hold on;
plot(y,x,'r');
hold off;

out=ones (size (I));
for p=1:256
    if x(p)>0 && x(p)<256 && y(p)>0 && y(p)<256
        out(x(p),y(p))=0;
    end
end

%figure, imshow(out, []),impixelinfo

%figure, imshow(out.*I_orig, []),impixelinfo
% ---------- 1st Peak End ---------


% ---------- 2nd Peak ---------
First_peak
A(First_peak(1,1)-10:First_peak(1,1)+10 , First_peak(1,2)-10:First_peak(1,2)+10) = 0;
%figure, imshow(A,[]), impixelinfo, title('A');

Second_peak =[];
max_A = max(max(A));
for i=1:size(A,1)
    for j=1:size(A,2)
        if A(i,j) == max_A
            t = i-1;
            r = j-r_min;
            Second_peak = [i, j];
        end
    end
end

if t>=45 && t<135
    x=0:max(size(I,1),size(I,2));
    y=round((r-x*cos(deg2rad(t)))/sin(deg2rad(t)));
else
    y=0:max(size(I,1),size(I,2));
    x=round((r-y*sin(deg2rad(t)))/cos(deg2rad(t)));
end

%figure, imshow(I,[]), impixelinfo, title('lines detected');
hold on;
plot(y,x,'r');
hold off;

out=ones (size (I));
for p=1:256
    if x(p)>0 && x(p)<256 && y(p)>0 && y(p)<256
        out(x(p),y(p))=0;
    end
end

%figure, imshow(out, []),impixelinfo

%figure, imshow(out.*I_orig, []),impixelinfo
% ---------- 2nd Peak End ---------


% ---------- 3rd Peak ---------
Second_peak
A(Second_peak(1,1)-10:Second_peak(1,1)+10 , Second_peak(1,2)-10:Second_peak(1,2)+10) = 0;
%figure, imshow(A,[]), impixelinfo, title('A');

Third_peak =[];
max_A = max(max(A));
for i=1:size(A,1)
    for j=1:size(A,2)
        if A(i,j) == max_A
            t = i-1;
            r = j-r_min;
            Third_peak = [i, j];
        end
    end
end
if t>=45 && t<135
    x=0:max(size(I,1),size(I,2));
    y=round((r-x*cos(deg2rad(t)))/sin(deg2rad(t)));
else
    y=0:max(size(I,1),size(I,2));
    x=round((r-y*sin(deg2rad(t)))/cos(deg2rad(t)));
end

%figure, imshow(I,[]), impixelinfo, title('lines detected');
hold on;
plot(y,x,'r');
hold off;

out=ones (size (I));
for p=1:256
    if x(p)>0 && x(p)<256 && y(p)>0 && y(p)<256
        out(x(p),y(p))=0;
    end
end

%figure, imshow(out, []),impixelinfo

%figure, imshow(out.*I_orig, []),impixelinfo
% ---------- 3rd Peak End ---------


Third_peak
A(Third_peak(1,1)-10:Third_peak(1,1)+10 , Third_peak(1,2)-10:Third_peak(1,2)+10) = 0;

figure, imshow(A,[]), impixelinfo, title('rho');



%%% ---------- Random Ploting -------------

%r=64;
%t=165;

if t>=45 && t<135
    x=0:max(size(I,1),size(I,2));
    y=round((r-x*cos(deg2rad(t)))/sin(deg2rad(t)));
else
    y=0:max(size(I,1),size(I,2));
    x=round((r-y*sin(deg2rad(t)))/cos(deg2rad(t)));
end

%figure, imshow(I,[]), impixelinfo, title('lines detected');
%hold on;
%plot(y,x,'r');
%hold off;

out=ones (size (I));
for p=1:256
    if x(p)>0 && x(p)<256 && y(p)>0 && y(p)<256
        out(x(p),y(p))=0;
    end
end
%figure, imshow(out, []),impixelinfo

%figure, imshow(out.*I_orig, []),impixelinfo
