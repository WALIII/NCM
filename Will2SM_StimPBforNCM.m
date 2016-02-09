% Parameters
SERIAL = 'COM9';
PIN = 12;
TIME_PREPARING = 2;
TIME_PLAYING = 8;
TIME_TRIGGERING = 0.1;

% Song
for i = 1:100

SONG_ARRAY = {song01,song02,song03,song04,song05,song06}
BOS = SONG_ARRAY{randi(6)}
Song = (BOS); % Make sure a stimulus called 'BOS' is loaded into Matlab's variables
fs = (fs); % Make sure the playback frequency called 'fs' is loaded into Matlab's variables

% Initialize audio
InitializePsychSound(1);

% Initialize arduino
arduino_instance = arduino(SERIAL);
arduino_instance.pinMode(PIN,'output');

% Load song once
PsychPortAudio('Close');
pahandle = PsychPortAudio('Open', [], 1, [], fs, 1, [], 0.025, [], []);
PsychPortAudio('FillBuffer', pahandle, Song');

disp(' Starting paradigm')

% Timing vector
time_trigger = []; % matrix, rows = number of iterations; columns = [year month day hour minute second]; time of beginning an iteration
profile_preparing = []; % vector, length = number of iterations; time spent preparing
profile_start = []; % vector, length = number of iterations; time spent preparing + starting audio


while true
    time_trigger(end + 1, :) = clock;
    tic; % start of preparing phase

    % open shutter
    disp('Open shutter.');
    arduino_instance.digitalWrite(PIN,1);
    pause(TIME_TRIGGERING);
    arduino_instance.digitalWrite(PIN,0);
    pause(TIME_PREPARING - TIME_TRIGGERING);

    profile_preparing(end + 1) = toc; % end of preparing phase

    % play song
    disp('Start BOS playback');
    PsychPortAudio('Start', pahandle);
    profile_start(end + 1) = toc; % time from trigger to start playing
    pause(TIME_PLAYING);

    % close shutter
    disp('Close shutter.');
    arduino_instance.digitalWrite(PIN,1);
    pause(TIME_TRIGGERING);
    arduino_instance.digitalWrite(PIN,0);
    end

end

randi([120,2000])

pause(randi([120,2000])) % wait until next trigger
end
