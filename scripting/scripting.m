% University of Verona - Bachelor's Degree in Computer Science 
% Biomedical Data and Signal Processing - Prof. Storti S.F.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lab 4 - EEGlab Scripting 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1.Load the EEG file and the channel locations

% Add path if toolboxes are missing
% addpath(genpath('.../FastICA25'))
% savepath ../FastICA25/pathdef.m
% Use the command 'EEG.history': run the functions from the GUI and when it 
% finishes type EEG.history in the matlab's command prompt

clear all; close all;

% Load eeglab
%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 
% Load *.edf data using the function pop_biosig
%[EEG, command] = pop_biosig('data_sub1_EOEC.edf', 'channels', [1:10 13:18 20:22]); 

% Load the channel location file elettrodes_10_20_SEI.sfp, enabling 
% automatic detection of channel file format
%EEG.chanlocs = pop_chanedit(EEG.chanlocs, 'load',{'elettrodes_10_20_SEI.sfp', 'filetype', 'autodetect'}); 
% Store the dataset into EEGLAB (create a new ALLEEG dataset 1)
%[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG); 

% OPPURE CARICO IL .SET se ci sono problemi di incompatibilità
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('data_sub1_EOEC.set');
eeglab redraw 
%non serve usare il comando pop_newset se si usa il. set

% Change the label of the events (use Type '2' for eyes closed (EC) and
% Type '4' for eyes open (EO) using the short script of Lab 3
for i=1:2:length(EEG.event)
EEG.event(i).type = 2;
EEG.urevent(i).type = 2;
end
for i=2:2:length(EEG.event)
EEG.event(i).type = 4;
EEG.urevent(i).type = 4;
end

% Update the EEGLAB window to view changes
eeglab redraw % Now CURRENTSET = 1
% Plot the data using a window of 15 s using the correct the frequency rate 
% and importing the channel location labels
eegplot(EEG.data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'});


%% 2. Filtering the data [1-30Hz]

% Apply separately a lowpass filter and an highpass filter using the
% function pop_eegfilt (FIR filter)
EEG = pop_eegfilt( EEG, 0, 30, [], [0], 0, 1, 'fir1', 0); % lowpass filter, cutoff: 30 Hz
EEG = pop_eegfilt( EEG, 1, 0, [], [0], 0, 1, 'fir1', 0);  % highpass filter, cutoff: 1 Hz

% Create a new dataset with the name 'EEG_FIL'
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL'); 

% Update the EEGLAB window to view changes
eeglab redraw % Now CURRENTSET = 2
% Plot the data after filtering
eegplot(EEG.data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'});

% You can compare the filtered EEG with the old one:
eegplot(ALLEEG(1).data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'});


%% 3. Baseline removal
% Perform a baseline removal on all channels data
EEG = pop_rmbase( EEG, [], []); 

% Create a new dataset with the name 'EEG_FIL_BAS'
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL_BAS'); 

% Update the EEGLAB window to view changes
eeglab redraw % Now CURRENTSET = 3
% Plot the data after baseline removal
eegplot(EEG.data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'});

% You can compare the new EEG with the previous one:
% eegplot(ALLEEG(2).data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'});


%% 4. Re-reference the data (use average reference)

% Re-reference the new dataset with an average reference using the function pop_reref
EEG = pop_reref( EEG, []); 
% Create a new dataset with the name EEG_FIL_BAS_AVE
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL_BAS_AVE');

% Update the EEGLAB window to view changes
eeglab redraw % Now CURRENTSET = 4
% Plot the data after re-referencing
eegplot(EEG.data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'});


%% 5. Interpolate bad channel(s)

% Interpolate bad data channel(s) using the function pop_interp and
% spherical method
EEG = pop_interp(EEG, [], 'spherical'); % T3
% Create a new dataset with the name EEG_FIL_BAS_AVE_INT
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL_BAS_AVE_INT') ;

% Update the EEGLAB window to view changes
eeglab redraw % Now CURRENTSET = 5
% Plot the data after bad channel(s) removal
eegplot(EEG.data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'});


%% 6. Run Independent Component Analysis (ICA) (using fastica)

% Apply ICA for data denoising: apply the decomposition using the function pop_runica
[EEG,com] = pop_runica(EEG,'icatype','fastica');
% Create a new dataset with the name EEG_FIL_BAS_AVE_INT_ICA
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL_BAS_AVE_INT_ICA') ;

% Update the EEGLAB window to view changes
eeglab redraw % Now CURRENTSET = 6
% Plot the independent components (ICs) before removal using the function 
% pop_eegplot (icacomp - type of rejection 0 = independent components)
pop_eegplot( EEG, 0, 0, 0); 
eegplot(EEG.data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'});

% Plot the components maps in 2-D (optional)
pop_topoplot(EEG, 0, [1:size(EEG.icawinv,2)] ,'EEG_FIL_BAS_AVE_INT_ICA',[4 5] ,0,'electrodes','on');


%% ICA denoising

% Visually identify components reflecting eyeblinks, movements, heartbeat,
% and other noises and then remove them using the function pop_subcomp
EEG = pop_subcomp( EEG, 1, 0);  % example of bad components: 1
% Visualize the ICs after removal
pop_eegplot(EEG, 0, 0, 0); 

% Update the EEGLAB window to view changes
eeglab redraw % CURRENTSET still = 6
% Plot the EEG after bad ICs removal
eegplot(EEG.data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'}); 


%% 7. Extracting all types of epochs after the events

% Extract epochs time locked to the event '2' and '4' from 0 to 2 s after those time-locking events
EEG = pop_epoch( EEG, {'2' '4'}, [0 2], 'newname', 'EOEC_epochs', 'epochinfo', 'yes');

% Create a new dataset with the name EOEC_epochs
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EOEC_epochs') ;

% Update the EEGLAB window to view changes
eeglab redraw % Now CURRENTSET = 7
% Plot the epochs after events (5 epochs per window)
eegplot(EEG.data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'}); 


%% Extract epochs Type 2 EC (eyes closed)

% Select epochs time locked to the events '2' EC
EEG = pop_selectevent( EEG,'type',2,'deleteevents','on','deleteepochs','on');
% Create a new dataset with the name EC_epochsT2
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EC_epochsT2');

% Update the EEGLAB window to view changes
eeglab redraw % Now CURRENTSET = 8
% Plot the epochs Type '2'
eegplot(EEG.data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',6,'color',{'k'}); 


%% Extract epochs Type 4 EO (eyes open)

% Select epochs time locked to the events '4' EO
% Pay attention, use the dataset that contains all the epochs and then select only those related to Type 4
EEG = pop_selectevent(ALLEEG(7), 'type',4,'deleteevents','on','deleteepochs','on');
% Create a new dataset with the name EO_epochsT4
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EO_epochsT4'); % Now CURRENTSET= 2

% Update the EEGLAB window to view changes
eeglab redraw % Now CURRENTSET = 9
% Plot the epochs Type '4'
eegplot(EEG.data,'srate',256,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',6,'color',{'k'}); 


%% 8. Calculate power spectra separately for the epochs '2' and epochs '4' with the same maplimits for all the topographic maps

% dataflag: if 1, process the input data channels; if 0, process its component activations
figure; 
title('Type 2 EC (eyes closed)'); 
pop_spectopo(ALLEEG(8), 1, [0 1996], 'EEG' , 'percent', 100, 'freq', [6 11 22], 'freqrange',[2 25],'electrodes','on','maplimits', [-8 8]); 
figure; 
title('Type 4 EO (eyes open)'); 
pop_spectopo(ALLEEG(9), 1, [0 1996], 'EEG' , 'percent', 100, 'freq', [6 11 22], 'freqrange',[2 25],'electrodes','on','maplimits', [-8 8]);

