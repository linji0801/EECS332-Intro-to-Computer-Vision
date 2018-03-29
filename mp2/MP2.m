function [l] = MP2(imagename,r,c)
%set up main function MP2(), where you can use any functions you want. It
%is used for testing each function. For the one you want to test, just
%activate the relative function and change the output of the main function. 
    SE = ones(r,c);
    d = RdIm(imagename);
    %e = Erosion(d, SE);
    %f = Dilation(d, SE);
    %g = Opening(d , SE);
    %h = Closing(d , SE);
    l = Boundary(d);
end

function [modelX, modelY] = MStructureElement(SE)
%For the structure element(SE) you establish, set the original point at the
%center of SE, and collect extra pixels' indexs in SE based on the center
%point's coordinate.
    [Rs , Cs] = size(SE);
    centerr = int32(Rs/2);
    centerc = int32(Cs/2);
    X = zeros();
    Y = zeros();
    for i = 1 : Rs
        for j = 1 : Cs
            if SE(i, j) == 1
                X = [X, (i - centerr)];
                Y = [Y, (j - centerc)];
            end
        end
    end
    %we collect the x and y seperately
    modelX = X;
    modelY = Y;
end

function img_in = RdIm(imagename)
%set up a function for inputing the image you want 
    img_in = imread(imagename,'bmp');
end

function img_out1 = Erosion(img_in , SE)
%establish the function of Erosion, where img_in and SE are the input while
%img_out1 is the output and it represents for the eroded image.
[r,c] = size(img_in);
finarr = zeros(r,c);
[modelX , modelY] = MStructureElement(SE);

%scan the whole img_in
for i = 1 : r
    for j = 1 : c
        pixel = img_in(i,j);
        if pixel ~= 0
        %for those pixels are not zero, define flagZero to judge the value
        %of neighbors of these pixels in the SE.
            flagZero = false;
            for k = 1 : length(modelX)
                x = (i + modelX(k));
                y = (j + modelY(k));
                if  x > 0  && x <= r  &&  y > 0 && y <= c
                %judge the boundary of the image, if there exists one zero
                %in the SE, than label such pixel as zero.
                    if img_in(x , y) == 0
                        finarr(i,j) = 0;
                        flagZero = true;
                        break;
                    end
                end
            end
            %If all neighbors are not zero, then label such pixel as one.
            if flagZero == false
                finarr(i,j) = 1;
            end
        end
    end
end
% From the upper operation, than we could get the eroded image.
img_out1 = finarr;
%If we want to test such function then output the following result.
%img_out1 = imagesc(finarr);
end

function img_out2 = Dilation(img_in , SE)
%establish the function of Dilation, where img_in and SE are the input while
%img_out2 is the output and it represents for the dilated image.
[r,c] = size(img_in);
finarr = zeros(r,c);
[modelX , modelY] = MStructureElement(SE);

%scan the whole img_in
for i = 1 : r
    for j = 1 : c
        pixel = img_in(i,j);
        if pixel == 0
         %for those pixels are zero, define flagZero to judge the value
        %of neighbors of these pixels in the SE.
            flagnotZero = false;
            for k = 1 : length(modelX)
                x = (i + modelX(k));
                y = (j + modelY(k));
                if  x > 0  && x <= r  &&  y > 0 && y <= c
                %judge the boundary of the image, if there exists a one
                %in the SE, than label such pixel as one.
                    if img_in(x , y) == 1
                        finarr(i,j) = 1;
                        flagnotZero = true;
                        break;
                    end
                end
            end
             %If all neighbors are zero, then label such pixel as zero.
            if flagnotZero == false
                finarr(i,j) = 0;
            end
        else
        %for those pixels equal to one, label them as one.
            finarr(i,j) = 1;
        end
    end
end
% From the upper operation, than we could get the dilated image.
img_out2 = finarr;
%If we want to test such function then output the following result.
%img_out2 = imagesc(finarr);
end

function img_out3 = Opening(img_in , SE)
%establish the function of Opening, where img_in and SE are the input while
%img_out3 is the output and it represents for the opening image. That is,
%we firstly erode the img_in, and then we dilate the eroded image, then we
%get the final opening image.
erodedimage = Erosion(img_in , SE);
dilatedimage = Dilation(erodedimage , SE);
img_out3 = imagesc(dilatedimage);
end

function img_out4 = Closing(img_in , SE)
%establish the function of Closing, where img_in and SE are the input while
%img_out4 is the output and it represents for the closing image. That is,
%we firstly dilate the img_in, and then we erode the dilated image, then we
%get the final closing image.
dilatedimage = Dilation(img_in , SE);
erodedimage = Erosion(dilatedimage , SE);
img_out4 = imagesc(erodedimage);
end

function img_out5 = Boundary(img_in)
%establish the function of Boundary, where img_in is the input and img_out5
%is the output and it represents for the boundary image. 
%Firstly, we estailished a 3*3 square SE.
%Secondly, erode the img_in.
%Thirdly, scan the eroded image, judge the value of pixels in eroded
%image.If it is equal to 1, then relabel the pixel in the img_in as zero.
%Finally, the relabeled img_in is so-called boundary image.
[r , c] = size(img_in);
SE = ones(3,3);
erodedimage = Erosion(img_in , SE);
for i = 1 : r
    for j = 1 : c
        if erodedimage(i,j) == 1
            img_in(i,j) = 0;
        end
    end
end
img_out5 = imagesc(img_in);
end




