function ProjectSets_sk4361_sp7612()

      img = imread('IMG_7534.jpg');
      
      %% Getting the region of interest that is the inside dark area where the cards lie.
      %We tried going pixel wise and finding the max dark region and then
      %cropping it out. Didn't work out. But we are sure that it will with
      %a few modifications.
%      
%      
%      imgk = img(:,:,1) + img(:,:,2) + img(:,:,3);
%      
%      imgb = imbinarize(img);
%      
%      figure()
%      imshow(img)
%      
%      [xn, yn] = size(img);
%      
% %      p1 = [0, 0];
% %      p2 = [0, 0];
% %      p3 = [0, 0];
% %      p4 = [0, 0];
% %      flag = 0;
%     %[ 
% %      for xi = 1 : xn
% %         if flag == 0 
% %         for yi = 1 : yn  
% %             if imgb(xi, yi) == 0 && flag == 0
% %                 flag = 1;
% %                 p1 = [xi, yi];
% %             end
% %             if flag == 1
% %                 if imgb(xi, yi) ~= 0
% %                     p2 = [xi, yi - 1];
% %                     break
% %                 end
% %             end
% %         end
% %         end
% %         y1 = p1(2);
% %         if imgb(xi, y1) ~= 0 && flag == 1 
% %             for yt = y1 : 1
% %                 if imgb(xi - 1, yt) ~= 0 || yt == 1
% %                     p3 = [xi - 1, yt + 1];
% %                     flag = 2;
% %                     break
% %                 end
% %             end      
% %         end
% %         
% %         if flag == 2
% %              y1 = p1(2);
% %             for yt = y1 : yn
% %                 if imgb(xi, yt) ~= 0 || yt == yn
% %                     p4 = [xi, yt - 1];
% %                 end
% %             end
% %         end
% %      end
% %     % 
% %      
% %    disp(p1)
% %    disp(p2)
% %    disp(p3)
% %    disp(p4)
%     
%   img = im2double(img);
%  % img = im2gray(img);
%   
%   hold on;
      figure()
      imshow(img)
   p1 = ginput(1);
   p2 = ginput(1);
   p3 = ginput(1);
   p4 = ginput(1);
   
   hold on;
   figure()
   imshow(img)
   
   p5 = ginput(1);
   p6 = ginput(1);
   p7 = ginput(1);
   p8 = ginput(1);
%% Projective transpose  
   moving = [p1; p2; p3; p4];
   fixed = [p5; p6; p7; p8];

  %trans = fitgeotrans(img, arr, 'projective');
   
  image = imwarp(img, fitgeotrans(moving, fixed, 'projective'));
  
  imwrite(image, "trans2.jpg")
  
  imshow(image)
  
%% Crop Image
  image = imread('trans2.jpg');
  
  img = image(:,:,1) + image(:,:,2) + image(:,:,3);
     
  imgb = imbinarize(img); 
  
  img = imcrop(image);
  
  imwrite(img, "cropped2.jpg")
     
 figure()
 imshow(img)
   
%% Get components / cards  
    im = imread('cropped.jpg');

    %Convert the image into gray channel
        img = im2gray(im);  
        
        %Adjust the contrast of the image
        img = imadjust(img, [0.6 0.8]);
        
        %Convert the image into a binary image
        img = imbinarize(img);
        
        figure, imshow(img)
        
        %bwlabel to get the components
        image = bwlabel(img);
        
        %Get the region of the components
        measurements = regionprops('struct', image, 'BoundingBox', 'Area');
        
        
        %Get each of the components
        cc = bwconncomp(image);
        
        %Label each component
        cardlabels = labelmatrix(cc);
        %figure, imshow(im)
        
        disp(cc.NumObjects)
        
       % if cc.NumObjects < 15 && cc.NumObjects > 0
           %For each of the components
            cnt = 0;
 %% For each card           
            for i = 1:cc.NumObjects
                if measurements(i).Area > 100000 
                    cnt = cnt + 1;
                    disp("=======================card " + cnt + "=========================")
                    thisBB = measurements(i).BoundingBox;
                    rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
                    'EdgeColor','cyan','LineWidth',1 )
                
                    %Current Card
                    thisCard = cardlabels==i;
                
                    % Shapes are surrounded by Card and +50 pixels
                    thisShapes = bwareaopen(imfill(thisCard, 'holes') & ~thisCard, 50);
                
                   
                    shapesCC = bwconncomp(thisShapes);

                    n = shapesCC.NumObjects;


                    if n > 0 
                        disp("Count = " + n)

                    %bwlabel to get the components
                    shapes = bwlabel(thisShapes);
                    
                    measurements2 = regionprops('struct', shapes, 'BoundingBox', 'Perimeter','Area', 'Centroid', 'Extent','Eccentricity');
                    circularities = [measurements2.Perimeter].^2 ./ (4 * pi * [measurements2.Area]);
                    thisBB2 = measurements2(1).BoundingBox;
                    rectangle('Position', [thisBB2(1),thisBB2(2),thisBB2(3),thisBB2(4)],...
                 'EdgeColor','cyan','LineWidth',1 )

                    xcoord = floor((2 * ceil(thisBB2(1)) + thisBB2(3) - 1)/2);
                    ycoord = floor((2 * ceil(thisBB2(2)) + thisBB2(4) - 1)/2);
                    
                    %disp(xedge + " " + yedge)
                    rd = im(ycoord, xcoord, 1);
                    gr = im(ycoord, xcoord, 2);
                    bl = im(ycoord, xcoord, 3);
                    
                    whitecnt = 0; 
                    for cn = 1: 50
                        if im(ycoord, xcoord + cn, 1) > 200 &&  im(ycoord, xcoord + cn, 2) > 200 && im(ycoord, xcoord + cn, 2) > 190
                            whitecnt = whitecnt + 1;
                        else
                            rd = im(ycoord, xcoord + cn, 1);
                        end
                        
                    end
                   % disp("white count = " + whitecnt)
%% Shading
                    if whitecnt == 0
                        rd = im(ycoord, xcoord, 1);
                        disp("Solid Color")
                    elseif whitecnt > 45
                        disp("No Filling")
                    else
                       %disp(rd + " " + gr + " " + bl)
                        disp("Striped")        
                    end
                    
%% Color                    
                    if rd < 60
                        disp("Green")
                    elseif rd > 200
                        disp("Orange")
                    else
                        disp("Purple")
                    end

%% Shape 
                     if circularities(1) < 1.3 
                        disp("shape = oval")
                    elseif circularities(1) > 1.65 || measurements2(1).Eccentricity < 0.89
                            disp("shape = diamond") 
                    else
                          disp("shape = squiggle")
                    end

                    figure, imshow(thisShapes)

                    end      

                end
        end
end
        
        

