close all; % closes all figures

% read images and convert to single format
imname = ["gala.jpg", "man.jpg", "woman.jpg", "earth.jpg", "saturn.jpg", "dog.jpg", "cat.jpg"];
stack_images = ["gala.jpg", "man_woman_color_hybrid.jpg", "earth_saturn_color_hybrid.jpg", "dog_cat_color_hybrid.jpg"];

% i = 1;
% 
% while i < length(imname)
%     im12 = process(imname{i}, imname{i+1});   
%     i = i + 2;
% end

i = 1;

N = 7; % number of pyramid levels (you may use more or fewer, as needed)
for i = 1:length(stack_images)
    % %% Compute and display Gaussian and Laplacian Pyramids (you need to supply this function)
    pyramids(stack_images{i}, N);
end




function pyramids(name, N)
    close all;
    sigma = 1;
    im = im2single(imread(name));
    imG = rgb2gray(im); 
    for i = 1:N
        imGN = imgaussfilt(imG, sigma);
        sigma = sigma * 2;
        detail = mat2gray(imG - imGN);
        imG = imGN;
        subplot(2,N,i), imshow(imGN);
        subplot(2,N,N+i), imshow(detail);
    end

end

function im12 = process(name1, name2)
    im1C = im2single(imread(name1));
    im2C = im2single(imread(name2));

    % use this if you want to align the two images (e.g., by the eyes) and crop
    % them to be of same size
    [im2C, im1C] = align_images(im2C, im1C);

    im1 = rgb2gray(im1C); 
    im2 = rgb2gray(im2C);
    
    imwrite(im1,[name1(1:end-4)  '_grayed.jpg']);
    imagesc(log(abs(fftshift(fft2(im1)))));
    saveas(gcf,[name1(1:end-4) '_fft'],'jpg');

    imwrite(im2,[name2(1:end-4)  '_grayed.jpg']);
    imagesc(log(abs(fftshift(fft2(im2)))));
    saveas(gcf,[name2(1:end-4) '_fft'],'jpg');
    
    % uncomment this when debugging hybridImage so that you don't have to keep aligning
    % keyboard; 

    %% Choose the cutoff frequencies and compute the hybrid image (you supply
    %% this code)
    hybridImage(im1, im2, name1, name2, false);
    im12 = hybridImage(im1C, im2, name1, name2, true);
end

function im12 = hybridImage(im1, im2, name1, name2, color)
    sigma = [3 3];
    low1 = imgaussfilt(im1, sigma);
    low2 = imgaussfilt(im2, sigma);
    
    high1 = im1 - low1;
    
    im12 = (low2 + high1);
    
    %% Crop resulting image (optional)
    figure(1), hold off, imagesc(im12), axis image, colormap gray
    disp('input crop points');
    [x, y] = ginput(2);  x = round(x); y = round(y);
    im12 = im12(min(y):max(y), min(x):max(x), :);
    figure(1), hold off, imagesc(im12), axis image, colormap gray
    
    if color ~= true
        imwrite(low2,[name2(1:end-4)  '_lowpass.jpg']);
        
        imagesc(log(abs(fftshift(fft2(low2)))));
        saveas(gcf,[name2(1:end-4) '_lowpass_fft'],'jpg');
        
        imwrite(high1,[name1(1:end-4)  '_highpass.jpg']);
        
        imagesc(log(abs(fftshift(fft2(high1)))));
        saveas(gcf,[name1(1:end-4) '_highpass_fft'],'jpg');
        
        imagesc(log(abs(fftshift(fft2(im12)))));
        saveas(gcf,[name1(1:end-4) '_' name2(1:end-4) '_hybrid_fft'],'jpg');
        imwrite(im12,[name1(1:end-4) '_' name2(1:end-4) '_hybrid.jpg']);
    else
        imwrite(im12,[name1(1:end-4) '_' name2(1:end-4) '_color_hybrid.jpg']);
    end
end