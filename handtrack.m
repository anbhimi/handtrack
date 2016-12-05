%Matlab program for hand-shape orientation tracking
%Author : Reddy Gurunatha Swamy PARASARAM
%read and display the image
img=imread('hand.jpg');
figure(1)
imshow(img);title('Original image');

%convert and display grayscale image
irgb=rgb2gray(img);
figure(2)
imshow(irgb);title('Grayscale image');

%use a 2D median filter to filter ou the salt and pepper noise
ifil=medfilt2(irgb);
figure(3)
imshow(ifil);title('2D median filtered image');

%perform thresholding on the image 
level=graythresh(ifil);
ibw=im2bw(ifil,level);
figure(4)
imshow(ibw);title('Thresholded image');

%Dilate and erode the image with diamond and square structural element of size 2,3 resply
sedil=strel('diamond',2);
idil=imdilate(ibw,sedil);
figure(5)
imshow(idil);title('Dilated image');
seerd=strel('square',3);
ierd=imerode(idil,seerd);
figure(6)
imshow(ierd);title('Eroded image');
img=ierd;

%Find the centroid of the hand using regionprops
statcent = regionprops(img,'centroid');
figure(7)
imshow(img); hold on;
for x = 1: numel(statcent)
    plot(statcent(x).Centroid(1),statcent(x).Centroid(2),'r.');
end
disp 'Centroid coordinates = '
disp statcent(1).Centroid(1);
disp statcent(1).Centroid(2);

%Find the orientation of the hand using regionprops
statorie=regionprops(img,'orientation');
figure(8)
imshow(img); hold on;
for x=1:numel(statorie)
    plot(statorie(x).Orientation);
end
disp 'Stat orientation :'
disp statorie.Orientation%Angle of orientation with respect to horizontal
centx=statcent(x).Centroid(1);
centy=statcent(x).Centroid(2);

%Find the angle of rotation(theta) 
if (0< statorie.Orientation(1) <90) %case of hand pointing outwards in 1st quadrant
      theta=(90-statorie.Orientation);%Angle to be rotated ACW for vertical alignment
elseif (-90 < statorie.Orientation(1) < 0)%case of hand pointing outwards in 4th quadrant
      theta=(-90-statorie.Orientation);%Angle to be rotated ACW for vertical alignment
end

%Rotate the hand ACW by theta to get alignment
imrot=imrotate(img,theta);
figure(9)
imshow(imrot);hold on; title('Rotated image');
statcentr = regionprops(imrot,'centroid');
for x = 1: numel(statcentr)
    plot(statcentr(x).Centroid(1),statcentr(x).Centroid(2),'r.');
end

%contour
figure(10)
cont=imcontour(imrot,1);
imshow(cont);title('Contour of image');
