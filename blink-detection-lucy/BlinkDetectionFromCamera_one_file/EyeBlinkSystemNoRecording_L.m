% -------------------------------------------------------------------------
% A standalone system for blink detection
% (c) Mikel Galar & Lucy Kuncheva

clear
clc
close all force

% Set up the GUI ----------------------------------------------------------
set(0,'units','pixels')
Pix_SS = get(0,'screensize');
fig = figure('Pos',Pix_SS);

% Video window ------------------------------------------------------------
cam = webcam;
im = rgb2gray(snapshot(cam));
szim = size(im);
msz = max(szim);
a_preview = axes('Un','N','Pos',[0.3 0.2 0.4 0.6]);
axis off
imshow(im)

% Text --------------------------------------------------------------------
te = annotation('textbox',[0.16,0.86,0.4,0.04],'String',...
    'Select a window around the face and double-click');
set(te,'FontName','Candara','FontSize',12,...
    'HorizontalAlignment','Left','VerticalAlignment','Middle',...
    'EdgeColor','none')

% Choose the "pillow window" ----------------------------------------------
[crim,videoCropPosition] = imcrop(im); % (crop the pillow area)
szim = size(crim);
himg = image(zeros(size(crim))); % handle for the cropped image
set(himg,'cdata',crim);
hold on
axis off

% Prepare the eye box rectangles ------------------------------------------
eyeBox = rectangle('Position',[1 1 szim(2), szim(1)],'LineWidth',1.5,...
    'LineStyle','-','EdgeColor','g');
bboxPoints =  bbox2points([1 1 szim(2) szim(1)]);
compl = @(x) [x(:,1);x(1,1)];
eyeBoxPoints = plot(compl(bboxPoints(:,1)),compl(bboxPoints(:,2)),...
    'LineWidth',1.5,'LineStyle','-','Color','r');

% Initialise the detector functions ---------------------------------------
vs.detector = vision.CascadeObjectDetector; % face detector
% vs.detector = vision.CascadeObjectDetector('EyePairBig'); % eye detector
% ('EyePairBig' for eye area)
vs.pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Set parameters ----------------------------------------------------------
ri = 10; % report interval in seconds

blink_buffer_size = 10;

% "Mean BR at rest was 17 blinks/min"
% "The normal control rate of 24 blinks per minute"

% Running -----------------------------------------------------------------

flag_track = false;
flag_lost = true;

FC = []; % frame counter
SED = [];

i = 1;
while true
    [t1,t2] = deal(clock);
    
    UN = 0;
    BL = 0; % number of blinks (red)
    
    fc = 0;
    while etime(t2, t1) <= ri % report interval
        im = imcrop(rgb2gray(snapshot(cam)),videoCropPosition);
        set(himg,'cdata',im);
        fc = fc + 1; % frame counter within one time-interval
        if ~flag_track
            eyebuff = [];
            BBoxAll = vs.detector.step(im);
            nE = size(BBoxAll, 1);
            if nE == 0 % no face ---------------------------
                flag_lost = true;
            else
                % eyes -------------------------------------
                
                if nE > 1 % there should be only one face
                    [~,indexmax] = max(BBoxAll(:, 3)); % take the widest
                    BBox = BBoxAll(indexmax, :);
                else
                    BBox = BBoxAll;
                end
                
                if BBox(3) < 0.5*szim(2) % not a face
                    flag_lost = true;
                else         
                    flag_lost = false;
                    % Take eyes from face
                    BBeye(2) = BBox(1,2) + 0.25*BBox(1,4);
                    BBeye(4) = 0.25*BBox(1, 4);
                    BBeye(1) = BBox(1,1) + 0.15*BBox(1,3);
                    BBeye(3) = 0.7*BBox(1,3);
                    BBox = round(BBeye);
                    bboxPoints_o = bbox2points(BBox); % original
                    
                    % Find corner points inside the detected region.
                    points = detectMinEigenFeatures(im,'ROI', BBox);
                    
                    % Re-initialize the point tracker.
                    xyPoints = points.Location;
                    
                    oldPoints = xyPoints;
                    release(vs.pointTracker);
                    initialize(vs.pointTracker, xyPoints, im);
                    set(eyeBox,'Visible','on','Position',BBox);
                    
                    
                    set(te,'String','Eyes detected','BackgroundColor','g')
                    flag_track = true;
                    eyebuff = []; % initialise the eye buffer
                end
            end
        else
            % Continue tracking
            [xyPoints, isFound] = step(vs.pointTracker,im);
            visiblePoints = xyPoints(isFound, :);
            oldInliers = oldPoints(isFound, :);
            
            if size(visiblePoints,1) > 30
                [xform, ~, visiblePoints] = ...
                    estimateGeometricTransform(...
                    oldInliers, visiblePoints, ...
                    'similarity', 'MaxDistance', 4);
                
                % Apply the transformation to the bounding boxes
                bboxPoints = transformPointsForward(xform, ...
                    bboxPoints_o);
                
                set(eyeBoxPoints,'Visible','on',...
                    'XData',compl(bboxPoints(:,1)),...
                    'YData',compl(bboxPoints(:,2)));
                
                set(eyeBox,'Visible','off')
                
                set(te,'String','Eyes detected','BackgroundColor','g')
                
                % The new box shouldn't be too far away from the original
                % bounding box. If it is, we might have lost tracking
                
                sed = sum((bboxPoints_o(:) - bboxPoints(:)).^2);
                % (squared Euclidean distance)
                SED = [SED,sed];

                if sed > 200 % threshold for squared distance
                    flag_lost = true;
                else
                    
                    % Find the middle and then centre the eye Box
                    centre_new = mean(bboxPoints);
                    outer_rect = [centre_new(1)-BBox(3)/2,...
                        centre_new(2)-BBox(4)/2,...
                        BBox(3:4)];
                    eyeImage = double(imcrop(im,outer_rect));
                    set(eyeBox,'Visible','on','Position',outer_rect);
                    
                    if size(eyebuff,3) < blink_buffer_size
                        eyebuff(:,:,end+1) = eyeImage;
                    else
                        % check the difference with the eye buffer
                        mean_eye_buff = mean(eyebuff,3);
                        y = mean2(abs(mean_eye_buff-eyeImage)>15);
                        if y > 0.1 && y < 0.4
                            BL = BL + 1;
                            set(te,'String','BLINK',...
                                'BackgroundColor','r')
                            eyebuff = eyebuff(:,:,end);
                        elseif y <= 0.1
                            % static
                            if size(eyebuff,3) > 10
                                eyebuff(:,:,1) = [];
                            end
                            eyebuff(:,:,end+1) = eyeImage;
                            set(te,'String','Eyes detected',...
                                'BackgroundColor','g')
                        else
                            set(te,'String',...
                                'Movement','BackgroundColor','y')
                            flag_track = false;
                            release(vs.pointTracker);
                            release(vs.detector);
                        end
                    end
                end
            else
                flag_lost = true;
            end
            
        end
        t2 = clock;
        if flag_lost
            flag_track = false;
            release(vs.pointTracker);
            release(vs.detector);
            UN = UN + 1;
            set(te,'String','Lost tracking','BackgroundColor','y')
            set(eyeBox,'Visible','off')
            set(eyeBoxPoints,'Visible','off')
        end
        
    end
    FC = [FC, fc];
    
    i = i + 1;
    
    drawnow
    pause(0.001);
    
end
