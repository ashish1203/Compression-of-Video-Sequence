% Fuzzy distance based compression of the video  with three membership
% functions

clc;
clear all;
index_fd=[];
outputFolder = 'C:\Users\admin\Desktop\KKB\frames';  % Change this!
% Read in the movie.

V=mmreader('BMW.avi');
%V=mmreader('BMW.avi');
nof=V.NumberOfFrames;
vidHeight = V.Height;
vidWidth = V.Width;
mov(1:nof) = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),... 
    'colormap', []);
%picking first frame to define size of the frame
nf=uint8((nof/10));
Dt(nf)=0;
Dt=uint32(Dt);
mov(1).cdata=read(V,2);
fr=mov(1).cdata;
Bfr_size = size(fr);             
width = Bfr_size(2);
height = Bfr_size(1);
iter=1;
sum=0;
sum=uint32(sum);

for frame = 1 :10: nof
% Extract the frame from the movie structure.
    mov(iter).cdata=read(V,frame);
  
    fr = mov(iter).cdata;
    cform=makecform('srgb2lab');
    fr_lab=applycform(fr,cform);
    if frame==1
       B=fr_lab;
       prev_fr_lab=B;
    else
       diff=fr_lab(:,:,1)-prev_fr_lab(:,:,1);
       
       for k=1:size(diff,1)
           for l=1:size(diff,2)
               if diff(k,l)<=50
                   diff(k,l)=0;
               end
           end
       end
       
       
       
       Dis=0;
       diff=uint32(diff);
       Dis=uint32(Dis);
       for i=1:size(diff,1)
        for j=1:size(diff,2)
          Dis=Dis+(diff(i,j));
        end
       end
       Dis=abs(Dis)
       Dt(iter)=(Dis)
       frame 
       iter
        display('hello');
       sum=sum+Dis;
    end
    
   

    iter=iter+1; 
    prev_fr_lab=fr_lab;
end
Dt=uint32(Dt);
%Dt=Dt(1,4:uint8((nof/10)-5));
%Dt=Dt(1,1:);
data1=Dt';
 %s=xlswrite('videocmprs.xls',data1,'Sheet1','B1');
%Dt=int16(Dt);
%mu_d=sum(Dt)/size(Dt,1);
mu_d=sum/iter;
mu_d=uint32(mu_d);

A=mu_d-mu_d*0.6;
B=mu_d-mu_d*0.4;
C=mu_d-mu_d*0.1;
D=mu_d+mu_d*0.1;
E=mu_d+mu_d*0.5;
F=mu_d+mu_d*3;
A=uint32(A);
B=uint32(B);
C=uint32(C);
D=uint32(D);
E=uint32(E);
F=uint32(F);


for k=1:size(Dt,2)
    if Dt(1,k)>=F
        Dt(1,k)=F;
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
keyframe_logic=zeros(uint8(nof/10),1);
keyframe_logic(1,1)=1; % Assume first frame is a keyframe.
min=0;
index_fd=3;
for k=2:size(Dt,2)
    
   input=Dt(1,k);
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
       ind=3;
             keyframe_logic(k,1)=1;
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
            keyframe_logic(k,1)=0;
       else
           keyframe_logic(k,1)=1;
       end
   end
index_fd=[index_fd ind];

end

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
   
data=horzcat(Dt',keyframe_logic);
data=horzcat(data,index_fd');
s1=xlswrite('videocmprs.xls',data,'Sheet1','D1');