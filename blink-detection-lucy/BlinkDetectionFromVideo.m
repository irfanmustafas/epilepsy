% -------------------------------------------------------------------------
% A standalone system for blink detection
% (c) Lucy Kuncheva & Mikel Galar

clear
clc
close all force

global detector pointTracker flag_lost

% Set up the GUI ----------------------------------------------------------
set(0,'units','pixels')
Pix_SS = get(0,'screensize');
fig = figure('Pos',Pix_SS);

% Video window ------------------------------------------------------------
% obj = VideoReader('video1.mp4');
% obj = VideoReader('video2.mp4');
% obj = VideoReader('video3.wmv');
% obj = VideoReader('video4.wmv');
obj = VideoReader('../data/video5.mp4');
for i = 1:40
    im = rgb2gray(readFrame(obj));
end
a_preview = axes('Un','N','Pos',[0.3 0.2 0.4 0.6]);
axis off
imshow(im)

% Text --------------------------------------------------------------------
te = annotation('textbox',[0.3,0.76,0.3,0.04],'String',...
    'Select a window around the face and double-click');
set(te,'FontName','Candara','FontSize',12,...
    'HorizontalAlignment','Left','VerticalAlignment','Middle',...
    'EdgeColor','none','BackgroundColor','w')

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
detector = vision.CascadeObjectDetector; % face detector
% detector = vision.CascadeObjectDetector('EyePairBig'); % eye detector
% ('EyePairBig' for eye area)
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Set parameters ----------------------------------------------------------
ri = 10; % report interval in seconds

blink_buffer_size = 10;
% "Mean BR at rest was 17 blinks/min"
% "The normal control rate of 24 blinks per minute"

% Running -----------------------------------------------------------------

flag_lost = true;

FC = []; % frame counter
i = 1;
while hasFrame(obj)
    [t1,t2] = deal(clock);
    BL = 0; % number of blinks (red)
    UN = 0;
    fc = 0;
    while etime(t2, t1) <= ri && hasFrame(obj) % report interval
        x = readFrame(obj);
        im = imcrop(rgb2gray(x),videoCropPosition);
        set(himg,'cdata',im);
        drawnow
        fc = fc + 1; % frame counter within one time-interval
        
        if flag_lost
            set(eyeBox,'Visible','off')
            set(eyeBoxPoints,'Visible','off')
            
            flag_lost = false;
            [BBox,xyPoints] = detect_eye_box(im);
            if ~flag_lost
                set(eyeBox,'Visible','on','Position',BBox);
                set(te,'String','Eyes detected','BackgroundColor','g')
                eyebuff = []; % initialise the eye buffer
            end
        else
            % Continue tracking
            flag_lost = false;
            [outer_rect, xyPoints, bboxPoints] = ...
                track_eye_box(im, xyPoints, BBox);
            eyeImage = double(imcrop(im,outer_rect));
            if~flag_lost
                set(eyeBox,'Visible','on','Position',outer_rect);
                set(eyeBoxPoints,'Visible','on',...
                    'XData',compl(bboxPoints(:,1)),...
                    'YData',compl(bboxPoints(:,2)));
                P.blink_buffer_size = 10;
                P.grey_threshold = 10;
                P.noise_threshold = 0.1;
                P.blink_threshold = 0.6;
                [b, eyebuff] = ...
                    blink_detection(eyebuff, eyeImage,P);
                if b && ~flag_lost
                    set(te,'String','BLINK','BackgroundColor','r')
                else
                    set(te,'String','Eyes detected','BackgroundColor','g')                    
                end
            end
        end
        t2 = clock;
        if flag_lost
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
