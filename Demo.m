% This algorithm automatically adjusts product colours according to primary colour
% change

% Copyright 2020 Han Gong, University of East Anglia

% input (must be in bmp format)
% test image list
imgs = {'Toilet_Rolls.jpg','Table_Cleaner.jpg','lw252.jpg','lw481.jpg', ...
    'Toothpaste.jpg','Stockpot.jpg','Washing_Up_Liquid.jpg',...
    'Soap.jpg','Hair_Drier.jpg'};

n_img = numel(imgs);
% c - new colour (specify lab values)
c = [127,50,0]/255;

n_row = ceil(n_img/4+1);
subplot(n_row,4,1);
imshow(repmat(reshape(c,[1,1,3]),50,50));

for id = 1:n_img
    i = im2double(imread(['test_im/',imgs{id}]));
    tic;
    r = cc(i,c);
    toc;
    subplot(n_row,4,id+1);
    imshow(r);
end
