% clear all
clc
% close all

set(0,'units','pixels')
%Obtains this pixel information
Pix_SS = get(0,'screensize');

fig = figure('Pos',Pix_SS);
% Preview -----------------------------------------------------------------
a_preview = axes('Un','N','Pos',[0.05 0.6 0.28 0.35]);
% start the camera
% cam = videoinput('winvideo', 1);%, 'MJPG_320x240');
cam = webcam();
% start(cam)
im = snapshot(cam);
h = image(zeros(size(im)));
preview(cam,h)

% Blink windows -----------------------------------------------------------
a_blink01 = axes('Un','N','Pos',[0.05 0.45 0.9 0.1]);
hold on
set(gca,'FontName','Candara','FontSize',10)
grid on
title('Blinking pattern by minute')
p1 = bar(zeros(30,2)); % place hoder

a_blink30 = axes('Un','N','Pos',[0.05 0.27 0.9 0.1]);
hold on
set(gca,'FontName','Candara','FontSize',10)
grid on
title('Blinking pattern in the last 30 minutes')
p2 = bar(zeros(30,2)); % place hoder

% Alert bar ---------------------------------------------------------------
cm_alert = zeros(200,3);
t = 1:200; cm_alert(:,1) = flipud(t'); cm_alert(:,2) = t';
le = 0.3;
cm_alert = cm_alert/max(cm_alert(:));
annotation('rectangle',[0.05 0.15 0.9 0.04],'Color','k');
alb = annotation('rectangle',[0.05 0.15 le*0.9 0.04],...
    'FaceColor',cm_alert(round((1-le)*200),:));

% Text information --------------------------------------------------------
tbx = 0.4; % text block x
te(1) = annotation('textbox',[tbx,0.92,0.15,0.04],...
    'String','Start time:');
te(2) = annotation('textbox',[tbx+0.16,0.92,0.1,0.04],'String',...
    datestr(now));
te(3) = annotation('textbox',[tbx,0.86,0.15,0.04],...
    'String','Blink/Move/Lost tracking:');
te(4) = annotation('textbox',[tbx+0.16,0.86,0.1,0.04],'String','');
te(5) = annotation('textbox',[tbx,0.80,0.15,0.04],...
    'String','# blinks in the past 30 minutes:');
te(6) = annotation('textbox',[tbx+0.16,0.80,0.1,0.04],'String','');

set(te(1:2:end),'FontName','Candara','FontSize',10,...
    'HorizontalAlignment','Right','VerticalAlignment','Middle',...
    'EdgeColor','none')
set(te(2:2:end),'FontName','Candara','FontSize',10,...
    'HorizontalAlignment','Left','VerticalAlignment','Middle',...
    'BackgroundColor','w')

% Feed --------------------------------------------------------------------
buff = {snapshot(cam),snapshot(cam),snapshot(cam)};

MaxBlinks30 = 15; % 30*20;
% "Mean BR at rest was 17 blinks/min"
% "The normal control rate of 24 blinks per minute"

some_thr = 5; % random plug-in

vs = VideoSurveillance();

vs.initializeForWebcam(buff{3});


% Think about timer for doing data update in the figure
% Think about setting the parameters with respect to the size
% Think about annotations in the preview

% Show the percentage of correctly tracked time in each minute

stateAnnotation = annotation('textbox', [0.05,0.9,0.28,0.05],...
                    'String', 'State',...
                    'Color', 'y',...
                    'FontSize', 12,...
                    'FontWeight', 'Bold',...
                    'LineStyle', 'none');

i = 1;
v = zeros(1,30); % number of blinks per minute
notTracking = zeros(1,30); % percentage of time without tracking
while i < 200
    t1 = clock;
    w = [];
    
%     t2 = t1;
    t2 = clock;
    while etime(t2, t1) <= 5 % one minute
%         tic;
        im = snapshot(cam);
        vs.doLoop(im);
        
        
        if (vs.timer == 0)
            if (vs.state == 0)
                if (vs.blinking)
                    set(stateAnnotation, 'String', 'BLINKING!!');
                else
                    set(stateAnnotation, 'String', 'Tracking blinks...');
                end
            else
                set(stateAnnotation, 'String', ...
                    ['Waiting for estable image... state = ' num2str(vs.state)]);
            end
            pause(0.001);
        end
            
    
% %         % Calculate the value of interest
% %         temp = abs((double(buff{1})+double(buff{2})+double(buff{3}))/3 ...
% %             - double(im)); % random plug-in
% %         w = [w, mean(temp(:))]; % random plug-in
% %         buff(1) = [];
% %         buff{3} = im;
        t2 = clock;
    end
    % Calculate the minute statistics
    % # blinks, duration, ets.
    v(i) = getAndSetBlinking(vs); %mean(w > some_thr);    
    states = getAndSetPreviousStates(vs);
    notTracking(i) = 1 - sum(states == 0) / double(length(states));
    if i > 30
        v30 = v(end-29:end);
        notTracking30 = notTracking(end-29:end);
    else
        v30 = v;
        notTracking30 = notTracking;
    end
    set(p1(1),'YData', v) % blinks since start
    notTrackingAux = notTracking * max(v);
    set(p1(2),'YData', notTrackingAux) % blinks since start
    set(p2(1),'YData', v30)
    notTracking30Aux = notTracking30 * max(v30);
    set(p2(2),'YData', notTracking30Aux)
    le = min([1,sum(v30)/MaxBlinks30]);
    set(alb,'Position',[0.05 0.15 le*0.9 0.04],...
        'FaceColor',cm_alert(round((1-le)*199+1),:))
    
%     str = ['Tracking time: ' num2str( 100-notTracking(i), '%2.2f')  '%'];
    
    if vs.state == 0
        set(te(4)','String', 'Blink detection in process')
    elseif vs.state == 1
        set(te(4)','String', 'All moving')
    elseif vs.state == 2
        set(te(4)','String', 'Lost face tracking')
    elseif vs.state == 3
        set(te(4)','String', 'Face is moving')
    end

    set(te(6)','String',sum(v30))
    
    drawnow
    pause(0.001);
    i = i + 1;
end
