%% Setup
clear all; close all;

% project constants
Fs = 128;

% eeglab setup
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab; 

%% Load data from testeeglaboratorio.set
[EEG command] = pop_loadset('testeeglaboratorio.set');
% load the channel location from Standard-10-20-Cap19.loc
EEG.chanlocs = pop_chanedit(EEG.chanlocs, 'load',{'Standard-10-20-Cap19.locs', 'filetype', 'autodetect'}); 
EEG.setname = 'RAW';

% store the dataset into EEGLAB (create a new ALLEEG dataset 1)
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);

% Change the label of the events
%   4 -> Eyes open
%   2 -> Eyes close
for i=1:2:length(EEG.event)
EEG.event(i).type = 2;
EEG.urevent(i).type = 2;
end
for i=2:2:length(EEG.event)
EEG.event(i).type = 4;
EEG.urevent(i).type = 4;
end

eeglab redraw;

%% Plot the data
eegplot(EEG.data, 'srate', Fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength',15);

close;
%% (manual)Baseline removal
for i=1:1:width(EEG.data)
    EEG.data(:,i) = EEG.data(:,i) - mean(EEG.data(:,i));
end

eegplot(EEG.data, 'srate', Fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength',15);
close;

%% Bandpass filter - HP@1Hz & LP@25Hz
EEG = pop_eegfilt( EEG, 0, 25, [], [0], 0, 1, 'fir1', 0); % lowpass filter@25Hz
EEG = pop_eegfilt( EEG, 1, 0, [], [0], 0, 1, 'fir1', 0);  % highpass filter@1Hz
close;

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'BL_1_25');

eeglab redraw;

eegplot(ALLEEG(2).data, 'srate', Fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength',15);
close;

%% Re-referencing the data
EEG = pop_reref(EEG, []);

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'BL_1_25_RR');

eeglab redraw;

eegplot(ALLEEG(3).data, 'srate', Fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength',15);
close;

% eegplot(ALLEEG(3).data - ALLEEG(2).data, 'srate', Fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength',15);
% close;

%% Interpolate corrupted channels(if any)
EEG = pop_interp(EEG, []);

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'BL_1_25_RR_INT');

eeglab redraw;

eegplot(ALLEEG(4).data, 'srate', Fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength',15);
close;

% eegplot(ALLEEG(4).data - ALLEEG(2).data, 'srate', Fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength',15);
% close

%% ICA decomposition(fastica)
[EEG, command] = pop_runica(EEG, 'icatype', 'fastica');

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'BL_1_25_RR_INT_ICA');

eeglab redraw;

pop_topoplot(EEG, 0, [1:size(EEG.icawinv,2)] ,'BL_1_25_RR_INT_ICA',[4 5] ,0,'electrodes','on');
close; 

%% ICA denosising
% ICs: 
%   3  -> eye blinks
%   9  -> eye blinks (or 10 usually)
%   12 -> heart beat (or 13 usually)
% WARNING! This is not always the case, the decomposition may extract
% components in a different order
EEG = pop_subcomp( EEG, [3 9 12], 0); 

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'BL_1_25_RR_INT_ICA_DE');

eeglab redraw;

%% Extract epochs - type 2(eyes closed)

% Select epochs time locked to the events '2' EC
% EEG = pop_selectevent(ALLEEG(5), 'type', 2, 'deleteevents', 'on', 'deleteepochs', 'on');
[EEG, indices] = pop_epoch(ALLEEG(6), {'2'}, [0 2]);

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'BL_1_25_RR_INT_ICA_DE_epochsT2');
% eegplot(ALLEEG(7).data, 'srate', Fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength',15);

eeglab redraw;

%% Extract epochs - type 4(eyes opened)

% Select epochs time locked to the events '4' EO
[EEG, indices] = pop_epoch(ALLEEG(6), {'4'}, [0 2]);

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'BL_1_25_RR_INT_ICA_DE_epochsT4');
% eegplot(ALLEEG(8).data, 'srate', Fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength',15);

eeglab redraw;

%% Calculate PS - type 2(eyes closed) epochs
figure; 
title('Tipo 2 (occhi chiusi)'); 
pop_spectopo(ALLEEG(7), 1, [0 2000], 'EEG' , 'percent', 100, 'freq', [6 11 22], 'freqrange',[2 25],'electrodes','on','maplimits', [-8 8]); 

%% Calculate PS - type 4(eyes closed) epochs
figure; 
title('Tipo 4 (occhi aperti)'); 
pop_spectopo(ALLEEG(8), 1, [0 2000], 'EEG' , 'percent', 100, 'freq', [6 11 22], 'freqrange',[2 25],'electrodes','on','maplimits', [-8 8]);
