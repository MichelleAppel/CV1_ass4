function stitch(image1, image2)
%stitch stitches two images together.
% Input parameters:
%   image1, image2      Rgb or grayscale images.

% transform to grayscale if necessary
image1_rgb = image1;
image2_rgb = image2;
if size(image1, 3) == 3
image1 = rgb2gray(image1);
end
if size(image2, 3) == 3
image2 = rgb2gray(image2);
end

[ trans_matrix, inliers_im1, inliers_im2 ] = RANSAC(image1, image2);

t_image1 = transform(image1, trans_matrix);

[ h1, w1, ~ ] = size(t_image1);
[ h2, w2, ~ ] = size(image2);

inliers_im1_y = inliers_im1(1:2:end);
inliers_im1_x = inliers_im1(2:2:end);
inliers_im2_y = inliers_im2(1:2:end);
inliers_im2_x = inliers_im2(2:2:end);

% ty2 = round(mean(inliers_im1_y - inliers_im2_y)); % Translation of image2 wrt image1
% tx2 = round(mean(inliers_im1_x - inliers_im2_x)); % Translation of image2 wrt image1

ty2 = round(trans_matrix(6));
tx2 = round(trans_matrix(5));

im1_upperleft  = [ 1 , 1  ];
im1_upperright = [ 1 , w1 ];
im1_lowerleft  = [ h1, 1  ];
im1_lowerright = [ h1, w1 ];

im2_upperleft  = [  1,  1 ] - [ ty2, tx2 ];
im2_upperright = [  1, w1 ] - [ ty2, tx2 ];
im2_lowerleft  = [ h1,  1 ] - [ ty2, tx2 ];
im2_lowerright = [ h1, w1 ] - [ ty2, tx2 ];

stitch_miny = min([ im1_upperleft(1), im1_upperright(1), im1_lowerleft(1), im1_lowerright(1), ...
                    im2_upperleft(1), im2_upperright(1), im2_lowerleft(1), im2_lowerright(1) ]);
stitch_minx = min([ im1_upperleft(2), im1_upperright(2), im1_lowerleft(2), im1_lowerright(2), ...
                    im2_upperleft(2), im2_upperright(2), im2_lowerleft(2), im2_lowerright(2) ]);
stitch_maxy = max([ im1_upperleft(1), im1_upperright(1), im1_lowerleft(1), im1_lowerright(1), ...
                    im2_upperleft(1), im2_upperright(1), im2_lowerleft(1), im2_lowerright(1) ]);
stitch_maxx = max([ im1_upperleft(2), im1_upperright(2), im1_lowerleft(2), im1_lowerright(2), ...
                    im2_upperleft(2), im2_upperright(2), im2_lowerleft(2), im2_lowerright(2) ]);

ty = stitch_miny-1;
tx = stitch_minx-1;

stitched = zeros( stitch_maxy-ty, stitch_maxx-tx );

stitched(1:h1, 1:w1) = t_image1;
stitched(1-ty-ty2:h2-ty-ty2, 1-tx-tx2:w2-tx-tx2) = image2;

% close ALL
figure, imshow(mat2gray(stitched))

% figure, imshow(mat2gray(t_image1))
% figure, imshow(image2)
end