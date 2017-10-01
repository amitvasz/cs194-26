% CS194-26 (cs219-26): Project 3

close all; % closes all figures

% PART 1.1: Warmup:

% name of the input file
imname = ["fire.jpg"];

sharpenImage(imname{1})

% for i=1:length(imname)
%     sharpenImage(imname{i})
% end

function [gR, gG, gB] = blurImage(name, sigma)
    im = im2double(imread(name));
    red = im(:,:,1); % Red channel
    green = im(:,:,2); % Green channel
    blue = im(:,:,3); % Blue channel
    
    gR = imgaussfilt(red, sigma);
    gG = imgaussfilt(green, sigma);
    gB = imgaussfilt(blue, sigma);
    
end
function sharpenImage(name)
    im = im2double(imread(name));
    sigma = [2 2];
    
    [gR, gG, gB] = blurImage(name, sigma);
    
    imB = cat(3, gR, gG, gB);
    
%     figure, imshow(im);
%     figure, imshow(imB);
    
    detail = im - imB;
    
    alpha = 3;
    
    sharpened = im + alpha*detail;
    imwrite(sharpened,[name(1:end-4)  '_sharpened.jpg']);
    subplot(2,2,1), imshow(im)
    subplot(2,2,2), imshow(imB)
    subplot(2,2,3), imshow(detail)
    subplot(2,2,4), imshow(sharpened)
end
% function sharpenImageFilter(name)
%     sigma = 5;
%     
%     im = im2double(imread(name));
%     
%     log = fspecial('log', sigma); 
%     
%     bFinal = convn(im,2*log,'same');
%     imshow(bFinal);
%     
% %     rF = conv2(red,log,'same');
% %     rF = conv2(red,log,'same');
% %     rF = conv2(red,log,'same');
%     
% end