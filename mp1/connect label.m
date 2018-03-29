function [label img, num] = CCL(img)
    A = imread('test.bmp', 'bmp');
    [r,c]= size(A);
