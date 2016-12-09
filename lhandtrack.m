%Author : PRG SWAMY
clc;
clear all;
close all;
clf; 

%read and display the image
img=imread('hand.jpg');
%figure(1)
%imshow(img);title('Original image');

%convert and display grayscale image
irgb=rgb2gray(img);
figure(2)
imshow(irgb);title('Grayscale image');

%use a 2D median filter to filter ou the salt and pepper noise
ifil=medfilt2(irgb);
%figure(3)
%imshow(ifil);title('2D median filtered image');

%perform thresholding on the image 
level=graythresh(ifil);
ibw=im2bw(ifil,level);
%figure(4)
%imshow(ibw);title('Thresholded image');

%Dilate and erode the image with diamond and square structural element of size 2,3 resply
sedil=strel('diamond',2);
idil=imdilate(ibw,sedil);
%figure(5)
%imshow(idil);title('Dilated image');
seerd=strel('square',3);
ierd=imerode(idil,seerd);
%figure(6)
%imshow(ierd);title('Eroded image');
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
%centx=statcent(1).Centroid(1);
%centy=statcent(1).Centroid(2);

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

centx=statcentr(x).Centroid(1);
centy=statcentr(x).Centroid(2);
BW = imrot;
%contour
figure(10)
BW2 = bwmorph(BW,'remove');
%figure(11)
%imshow(BW2)
% cont=imcontour(imrot,1);
[imht imwt]=size(BW2);
% % a=zeros(imht,imwt);
% img(round(cont(1,:)),round(cont(2,:))) = 1;
% for i=1:1:size(cont,2)
%     a(round(cont(2,i)),round(cont(1,i))) = 1;
% end
% figure(11)
% imshow(img);    
%!!!! Problem : contour image height is too big 

%to extract reference point by given algorithm
j=0;
tmp=[];
I=imrot;
for i=1:imht
    if(I(i,round(centy))==1)
        j=j+1;
        tmp(j)=i;
    end
    xr=max(tmp);
    yr=centy;
end 
%figure(12)
%imshow(imrot);title('Rotated image with reference point');hold on;
%plot(yr,xr,'r.');
figure(13)
imshow(BW2);title('contour image with reference point ');hold on;
plot(yr,xr,'r.');

% centre = props.Centroid;
%dists = sqrt((rows-xr).^2 + (cols-yr).^2);
%max1=(max(dists));
%to find the distances of points on the contour to the reference point
[rows, cols] = find(BW2);
dist=zeros(imht,imwt);
for i=1:size(rows)
    x=rows(i,1);
    y=cols(i,1);
    dist(x,y)= sqrt((x-xr).^2+(y-yr).^2);
end

maxim=zeros(imht,imwt);
for i=2:size(rows)-1
    x=rows(i,1);
    y=cols(i,1);
    xp=rows(i-1,1);
    yp=cols(i-1,1);
    xn=rows(i+1,1);
    yn=cols(i+1,1);
    if(dist(x,y)> dist(xp,yp))
        if(dist(x,y)>dist(xn,yn))
            maxim(x,y)=1;
        end    
    end
end
%figure(14)
%imshow(maxim);title('Max distance points');
for i=1:size(rows)
    x=rows(i,1);
    y=cols(i,1);
    onedist(1,i)=dist(x,y);
end
[peaks,locs]=findpeaks(onedist);
onedist=medfilt1(onedist,10);
plot(onedist,'Color','blue'); hold on;
plot(locs,onedist(locs),'k^','markerfacecolor',[1 0 0]);
adist=imregionalmax(dist)
imshow(adist)

%Dilate and erode the image with diamond and square structural element of size 2,3 resply
sedil=strel('diamond',6);
adistdil=imdilate(adist,sedil);
%figure(5)
%imshow(idil);title('Dilated image');
seerd=strel('square',3);
adisterd=imerode(adistdil,seerd);

figure(14)
imshow(adisterd);title('Dilation and erosion');

%mean1=mean(onedist);
%meandist=mean(mean1);
%maxdist=zeros(imht,imwt);
%mindist=zeros(imht,imwt);
%for i = 1:imht
%   x=rows(i,1);
%   y=cols(i,1);
%  if(adist(x,y)> meandist)
%       maxdist(x,y)=1;
%%   elseif(adist(x,y)<meandist)
 %      mindist(x,y)=1;
 %  end
%end
%figure(15)
%imshow(maxdist);hold on;
%imshow(mindist);title('Max and min');