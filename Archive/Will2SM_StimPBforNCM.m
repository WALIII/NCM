function NCM_presenstation();


SERIAL = '/dev/cu.usbmodem1411';
PIN = 13;
TIME_PREPARING = 2;
TIME_PLAYING = 8;
TIME_TRIGGERING = 0.1;
fs = 48000;
load('songtest.mat');
% Initialize arduino
arduino_instance = arduino(SERIAL,'uno');
SONG_ARRAY = {song01,song02,song03,song04,song05,song06};



for i = 1:100
BOS = SONG_ARRAY{randi(6)};
Song = (BOS); % Make sure a stimulus called 'BOS' is loaded into Matlab's variables


disp(' Starting paradigm')
disp(' START Trigger')
   writeDigitalPin(arduino_instance, 'D13', 1);
   pause(5)
soundsc(BOS,fs);
pause(5)

disp(' END Trigger')
   writeDigitalPin(arduino_instance, 'D13', 0);

pause(5);

pause(randi([1,2])) % wait until next trigger


end
    
end



