%Histogram distance calcultionsize(mme)with three membership functions
% for BMW.avi video

clc;
clear all;
%V=mmreader('webcamface.avi');
V=mmreader('BMW.avi');
nof=V.NumberOfFrames;
vidHeight = V.Height;
vidWidth = V.Width;

mov(1:nof) = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),... 
    'colormap', []);

iter=1;

count_l(255)=0;
count_a(255)=0;
count_b(255)=0;
count_l=uint32(count_l);
count_a=uint32(count_a);
count_b=uint32(count_b);

for frame = 1 :10: nof
% Extract the frame from the movie structure.
    mov(iter).cdata=read(V,frame);
  
    fr = mov(iter).cdata;
    
    cform=makecform('srgb2lab');
    fr_lab=applycform(fr,cform);
    
    if frame==1
        prev_fr_lab=fr_lab;
    else
        hist_diff(:,:,1)=(prev_fr_lab(:,:,1)-fr_lab(:,:,1));
        hist_diff(:,:,2)=(prev_fr_lab(:,:,2)-fr_lab(:,:,2));
        hist_diff(:,:,3)=(prev_fr_lab(:,:,3)-fr_lab(:,:,3));
        hist_diff=uint32(hist_diff);
        
       count_l(255)=0;
count_a(255)=0;
count_b(255)=0;

        
        


        %Histogram for l component for every FFS frame diff
    for i=1:size(hist_diff,1)
        for j=1:size(hist_diff,2)
            for k=1:255
                if hist_diff(i,j,1)==k
                    count_l(k)=count_l(k)+hist_diff(i,j,1);
                end
                
            end
        end
    end
    
    countl=sum(count_l)
    
% hist for a component for every FFS frame
    for i=1:size(hist_diff,1)
        for j=1:size(hist_diff,2)
            for k=1:255
                if hist_diff(i,j,2)==k
                    count_a(k)=count_a(k)+hist_diff(i,j,2);
                end
            end
        end
    end
    
    counta=sum(count_a)
    
    % hist for b component for every FFS frame
        for i=1:size(hist_diff,1)
         for j=1:size(hist_diff,2)
            for k=1:255
                if hist_diff(i,j,3)==k
                    count_b(k)=count_b(k)+hist_diff(i,j,3);
                end
            end
          end
        end
        
        
        countb=sum(count_b)
       hh=(countl+countb+counta)./(3*size(hist_diff,1)*size(hist_diff,2));
       hh=uint32(hh);
       
       
    HDt(iter)=hh
    HDt=abs(HDt);
    HDt=uint32(HDt);
    end
    prev_fr_lab=fr_lab;
    iter=iter+1; 
end
 
mu_hd=uint32(sum(HDt)/iter);


A=mu_hd-mu_hd*0.6;
B=mu_hd-mu_hd*0.4;
C=mu_hd-mu_hd*0.2;
D=mu_hd+mu_hd*0.2;
E=mu_hd+mu_hd*0.4;
F=mu_hd+mu_hd*0.6;
%A=1924
%B=2566
%C=4169
%D=5773

A=uint32(A);
B=uint32(B);
C=uint32(C);
D=uint32(D);
E=uint32(E);
F=uint32(F);


index=[];


for l=1:size(HDt,2)
if HDt(l)>F
    HDt(l)=F;
end
end

% membership function definition
mem1(1:F)=0;
mem2(1:F)=0;
mem3(1:F)=0;
x=1:F;
mem1(1:A)=1;
mem1(A:B)=(((A:B)-A)./(A-B))+1;
mem2(A:C)=(((A:C)-C)./(C-A))+1;
mem2(C:D)=1;
mem2(D:E)=(((D:E)-D)./(D-E))+1;
mem3(D:E)=(((D:E)-E)./(E-D))+1;
mem3(E:F)=1;

plot(x,mem1,'r'),hold on, plot(x,mem2,'g');hold on, plot(x,mem3,'b');
%
% fuzzy decision
keyframe_logic=zeros(uint16(nof/10),1);
keyframe_logic(1,1)=1; % Assume first frame is a keyframe.

for k=2:size(HDt,2)
    
   input=HDt(1,k);
   if input==0
       input=1;
   end
   res1=mem1(input);
   res2=mem2(input);
   res3=mem3(input);
   if res1==1 && res2==0 && res3==0
             keyframe_logic(k,1)=0;
             ind=1;
   elseif res2==1 && res1==0 && res3==0
             keyframe_logic(k,1)=0;
             ind=2;
   elseif res3==1 && res1==0 && res2==0
             keyframe_logic(k,1)=1;
             ind=3;
   else
      
       if (res1*res2~=0&&res3==0)
            min=res1;
             ind=1;
          if min>res2
           min=res2;ind=2;
        
          end
       elseif (res2*res3~=0&& res1==0)
           min=res2;ind=2;
          if min> res3
              min=res3;ind=3;
          end
       end
       
       if ind==1
            keyframe_logic(k,1)=0;
       elseif ind==2
            keyframe_logic(k,1)=1;
       else
           keyframe_logic(k,1)=1;
       end
   end


   index=[index ind];
   
   
end





keyframe_logic


outputFolder = 'C:\Users\admin\Desktop\KKB\frames';  % Change this!

%placing first frame into disk
first_frame=mov(1).cdata;
% Create a filename.
outputBaseFileName = sprintf('Frame %4.4d.png', 1);
outputFullFileName = fullfile(outputFolder, outputBaseFileName);
% Write it out to disk.
imwrite(first_frame, outputFullFileName, 'png');
iters=1;
for frame = 1:10: nof
    
    % Extract the frame from the movie structure.
    if keyframe_logic(iters,1)==1
         
         thisFrame = mov(iters).cdata;
       
         % Create a filename.
         outputBaseFileName = sprintf('Frame %4.4d.png', frame);
         outputFullFileName = fullfile(outputFolder, outputBaseFileName);
          % Write it out to disk.
         imwrite(thisFrame, outputFullFileName, 'png');
    end
    iters=iters+1;
end
data=horzcat(HDt',keyframe_logic);%(row,1)   
data=horzcat(data,index');
s=xlswrite('videocmprs.xls',data,'Sheet1','A1');

