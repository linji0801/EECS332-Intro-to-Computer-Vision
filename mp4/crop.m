function img_out = crop(img_in)
%this function is used for croping the training images
 %Read in the input image
img_in = imread(img_in);

 %Open up the crop tool for the user
CropImg = imcrop(img_in);
img_out = imshow(CropImg);
end

