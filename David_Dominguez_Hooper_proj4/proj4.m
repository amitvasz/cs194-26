% CS194-26 (cs219-26): Project 4
% David Dominguez Hooper 24828373

close all; % closes all figures

imname = ["george.jpg", "jack.jpg"];

im1 = imresize(im2double(imread(imname{1})),[300 300]);
im2 = imresize(im2double(imread(imname{2})),[300 300]);

% Part 1: Defining Correspondences

load('im1_pts.mat', 'im1_pts');
load('im2_pts.mat', 'im2_pts');

% cpselect(im1,im2); %, im1_pts, im2_pts);
% 
% [h, w, chan] = size(im1);
% im1_pts = [im1_pts; 1,1; 1,h; w,1; w,h];
% im2_pts = [im2_pts; 1,1; 1,h; w,1; w,h];
% 
% save('im1_pts.mat', 'im1_pts');
% save('im2_pts.mat', 'im2_pts');


% PART 2: Computing the "Mid-way Face"

% mid_pts = (im1_pts + im2_pts)/2;
% tri = delaunay(mid_pts); % triangle pts for both images
% 
% im_mid1 = morph_mid(im1, im2, im1_pts, mid_pts, tri, 0, 0);
% figure, imshow(im_mid1);
% imwrite(im_mid1, [imname{1}(1:end-4) '_mid.jpg']);
% 
% im_mid2 = morph_mid(im2, im2, im2_pts, mid_pts, tri, 0, 0);
% figure, imshow(im_mid2);
% imwrite(im_mid2, [imname{2}(1:end-4) '_mid.jpg']);
% 
% mid_face = im_mid1*0.5 + im_mid2*0.5;
% figure, imshow(mid_face);
% imwrite(mid_face, [imname{1}(1:end-4) '_' imname{2}(1:end-4)  '_mid.jpg']);


% PART 3: The Morph Sequence

% morph_rate = 1/20; % Morphing rate
% 
% vidWriObj = VideoWriter('morph.avi');
% 
% vidWriObj.FrameRate = 4;
% open(vidWriObj);
% 
% for frac = 0 : morph_rate : 1
%     warp_frac     = frac; 
%     dissolve_frac = frac; 
%     
%     morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);
%     
%     imshow(morphed_im); axis image; axis off; drawnow;
%     writeVideo(vidWriObj, getframe(gcf));
% end
% close(vidWriObj);
% clear vidWriObj;

% PART 4: The "Mean face" of a population





dirData = dir('**/data/*');
dirData = dirData(3:end, :);
num_imgs = length(dirData)/2;

for i = 1 : 2: num_imgs
    imdata =  dirData(i).name;
    
    fid = fopen(['./data/' imdata]);
    tline = fgetl(fid);
    
    for j = 1:9
        disp(tline)
        tline = fgetl(fid);
    end
    num_pts = str2double(tline);

    for j = 1:7
        disp(tline)
        tline = fgetl(fid);
    end
    for j = 1:num_pts
        disp(tline)
        str = strsplit(tline);
        tline = fgetl(fid);
    end
    
    
    fclose(fid);
end


% PART 5: Caricatures: Extrapolating from the mean


% PART 6: Bells and Whistles #1


% PART 7: Bells and Whistles #2


% Functions:

function A = computeAffine(tri1_pts,tri2_pts)
    r1 = [tri1_pts(1, :), 1];
    r2 = [tri1_pts(2, :), 1];
    r3 = [tri1_pts(3, :), 1];
    x = vertcat(r1, r2, r3).';
    
    r1 = [tri2_pts(1, :), 1];
    r2 = [tri2_pts(2, :), 1];
    r3 = [tri2_pts(3, :), 1];
    
    b = vertcat(r1, r2, r3).';
    
    A = b*x^-1;
    A(3, :) = [0, 0, 1];
    
end

function morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);
    num_tris = length(tri);
    aff_trans_matrices = cell(num_tris, 2);

%     figure, set(gca,'Ydir','reverse'), triplot(tri1, im1_pts(:, 1), im1_pts(:, 2));
    immid_pts = (1 - warp_frac) * im1_pts + warp_frac * im2_pts;
    
    for i = 1:num_tris
        aff_trans_matrices{i, 1} = computeAffine(im1_pts(tri(i, :), :), immid_pts(tri(i, :), :)); 
        aff_trans_matrices{i, 2} = computeAffine(im2_pts(tri(i, :), :), immid_pts(tri(i, :), :));
    end

    [h, w, ~] = size(im1);
    [X, Y] = meshgrid(1:w, 1:h);
    [XN1, YN1] = meshgrid(1:w, 1:h);
    [XN2, YN2] = meshgrid(1:w, 1:h);
    
    
    t = mytsearch(immid_pts(:,1), immid_pts(:,2), tri, X, Y);


    for i = 1:h %y
        for j = 1:w %x
            t_m1 = aff_trans_matrices{t(i, j), 1};
            t_m2 = aff_trans_matrices{t(i, j), 2};
            
            new1 = t_m1^-1*([j, i, 1].');
            new2 = t_m2^-1*([j, i, 1].');
            
            XN1(i, j) = new1(1, :);
            YN1(i, j) = new1(2, :);
            XN2(i, j) = new2(1, :);
            YN2(i, j) = new2(2, :);
        end
    end
    rgb1 = cell(3);
    rgb2 = cell(3);
    for i = 1:3
        rgb1{i} = interp2(im1(:, :, i),XN1,YN1,'linear');
        rgb2{i} = interp2(im2(:, :, i),XN2,YN2,'linear');
    end
    
    morphed_im1 = cat(3, rgb1{1}, rgb1{2}, rgb1{3});
    morphed_im2 = cat(3, rgb2{1}, rgb2{2}, rgb2{3});
    morphed_im = (1-dissolve_frac) * morphed_im1 + dissolve_frac * morphed_im2;
%     figure, imshow(morphed_im);
end
function morphed_im = morph_mid(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);
    num_tris = length(tri);
    aff_trans_matrices = cell(num_tris, 1);

%     figure, set(gca,'Ydir','reverse'), triplot(tri1, im1_pts(:, 1), im1_pts(:, 2));

    for i = 1:num_tris
        aff_trans_matrices{i} = computeAffine(im1_pts(tri(i, :), :), im2_pts(tri(i, :), :)); 
    end

    [h, w, ~] = size(im1);
    [X, Y] = meshgrid(1:w, 1:h);
    [XN, YN] = meshgrid(1:w, 1:h);
    t = mytsearch(im2_pts(:,1), im2_pts(:,2), tri, X, Y);


    for i = 1:h %y
        for j = 1:w %x
            t_m = aff_trans_matrices{t(i, j)};
            new = t_m^-1*([j, i, 1].');
            XN(i, j) = new(1, :);
            YN(i, j) = new(2, :);
        end
    end
    rgb = cell(3);
    for i = 1:3
        rgb{i} = interp2(im1(:, :, i),XN,YN,'linear');
    end
    morphed_im = cat(3, rgb{1}, rgb{2}, rgb{3});
end