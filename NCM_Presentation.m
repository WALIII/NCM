function NCM_Presentation();
  % NCM_Presentation();

  % Play a Variety of different stimulli to NCM implanted Birds

  %   Created: 2016/15/12
  %   By: WALIII
  %   Updated: 2016/15/15
  %   By: WALIII

  % NCM_Presentation will do several things:
  %
  %   1.  Play different songs (pre-loaded in 'songtest.mat') at irregular
  %       intervals, for 100 10 second trials ~33 minutes of imaging
  %       thorught the day.
  %   2.  Record what was played, and the inter-stimulus interval of
  %       playing ( in a .csv file) **BETA**
  % 



load('songtest.mat');

% Initialize arduino
SERIAL = '/dev/cu.usbmodem1411';
arduino_instance = arduino(SERIAL,'uno');
% load in different songs to be played randomly throughout the day: 
SONG_ARRAY = {song01,song02,song03,song04,song05,song06}; 
fs = 48000; % frequency of the audio recordings




for i = 1:100 % for n trials (100)
BOS = SONG_ARRAY{randi(6)}; % pick 1 of the 6 trials randomly 
% Make sure a stimulus called 'BOS' is loaded into Matlab's variables


disp(' Starting paradigm')
%disp(' START Trigger')
tic
   writeDigitalPin(arduino_instance, 'D13', 1); % Write digital pin 13 high
pause(5) % 5 seconds of imaging before the stimulus
soundsc(BOS,fs); % Play the stimulus of choice. 
pause(size(song01,1)/fs) % add the lenght of the stimulus to the recording durration
pause(5)% 5 seconds of imaging after the stimulus
toc
%disp(' END Trigger')
   writeDigitalPin(arduino_instance, 'D13', 0);% Write digital pin 13 low

pause(5); % Wait as to not overflow the buffer ( add 5 seconds to the 
          % minimim wait time....

pause(randi([1,2])) % wait until next trigger

clear BOS % clear the buffer
end
   
end



