%clear all
%clc
%close all

function Labels = LabellingGUI(videoFile)

% Notes:-------------------------------------------------------------------
%
% 1: All frames are "Open" by default. Click on the button to label the
% frame "Closed". Toggle back to "Open" if you made a mistake.
%
% 2. After finishing the page, move the mouse outside of any button, click,
% and press a keyboard key for the next page with frames. There is no
% provision to return to pages that have been marked already.
% 
% 3. After the last page, the programme will finish and a variable "Labels"
% will be available. It contains 1 for frames with open eyes and 2 for
% frames with closed eyes. Store Labels in a file of your choice, e.g.
%
% save Will_72cm.seated.light.move_Labels Labels
%--------------------------------------------------------------------------

if nargin == 0
    disp('No input file provided.');
    disp('Directory contents:')
    videoFile = [pwd '\' input('Please select a video file > ', 's')];
end

v = VideoReader(videoFile); % set up video object

P = get(0,'ScreenSize');
figure('Pos',P) % figure on the whole screen

k1 = 5; % columns of frames
k2 = 4; % rows of frames

nFrames = round(v.Duration * v.FrameRate);
nPages = ceil(nFrames / (k1 * k2));

fprintf('\n%s \n\t%d x %d @ %.2fFPS\n',v.Name,v.Width,v.Height,v.FrameRate)
fprintf('\t%s, %dBPP',v.VideoFormat, v.BitsPerPixel)

F = k1*k2;
h = zeros(1,F); % handles for the axes
b = zeros(1,F); % handles for the buttons
axis_counter = 1;
aw = 0.9/k1; % axes width
ah = 0.9/k2; % axes height
axis off;

for j = 1:k2
    for i = 1:k1
        h(axis_counter) = axes('Units','Normalized','Pos',...
            [(i-1)*aw+0.1,(k2-j)*ah+0.1,...
            0.8*aw,0.8*ah]); % create a pair of axes
        axis off
        
        b(axis_counter) = uicontrol('Un','N','BackgroundColor','g',...
            'Position',[(i-1)*aw+0.1,(k2-j)*ah+0.15,0.04,0.03],...
            'FontSize', 10,'FontName','Candara','String','Open',...
            'Callback',['if strcmp(get(gco,''String''),''Open''),',...
            'set(gco,''String'',''Closed'',',...
            '''BackgroundColor'',''r''),else,',...
            'set(gco,''String'',''Open'',',...
            '''BackgroundColor'',''g''),end']);
        axis_counter = axis_counter + 1;
    end
end

Labels = [];
flag = true;
page = 0;
while flag
    for i = 1:F
        cla(h(i)) % clear the old plots
    end
    drawnow
    % try to fill a page with frames
    frame_to_fit = 0;
    set(b,'String','Open','BackgroundColor','g')
    while hasFrame(v) && frame_to_fit < k1*k2
        frame_to_fit = frame_to_fit + 1;
        vidFrame = readFrame(v);
        axes(h(frame_to_fit))
        imshow(vidFrame)
    end
    page = page + 1;
    xlabel(sprintf('Page %d of %d', page, nPages));
    pause
    L = ones(F,1); % read the labels to store
    flag = hasFrame(v);
    L(strcmp(get(b,'String'),'Closed')) = 2;
    Labels = [Labels;L(1:frame_to_fit)];
end

end