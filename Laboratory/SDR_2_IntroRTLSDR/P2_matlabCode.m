
function P2_matlabCode

%% PARAMETERS
rtlsdr_id           = '0';          % RTL-SDR ID
rtlsdr_tunerfreq    = 100e6;        % freqüència del tuner del RTL-SDR
rtlsdr_gain         = 25;           % Guany del tuner RTL-SDR en dB
rtlsdr_fs           = 2.4e6;        % Freqüència de mostreig RTL-SDR
rtlsdr_frmlen       = 4096;         % Mida del frame de sortida del RTL-SDR
rtlsdr_datatype     = 'single';     % Tipus de datos del RTL-SDR
rtlsdr_ppm          = 0;            % correcció del tuner del RTL-SDR en parts per milió
sim_time            = 60;           % Duradad de la simulació

%% SYSTEM OBJECTS
% rtl-sdr object
obj_rtlsdr = comm.SDRRTLReceiver(...
    rtlsdr_id,...
    'CenterFrequency', rtlsdr_tunerfreq,...
    'EnableTunerAGC', false,...
    'TunerGain', rtlsdr_gain,...
    'SampleRate', rtlsdr_fs, ...
    'SamplesPerFrame', rtlsdr_frmlen,...
    'OutputDataType', rtlsdr_datatype ,...
    'FrequencyCorrection', rtlsdr_ppm );

% spectrum analyzer objects
obj_specfft = dsp.SpectrumAnalyzer(...
    'Name', 'Spectrum Analyzer FFT',...
    'Title', 'Spectrum Analyzer FFT',...
    'SpectrumType', 'Power density',...
    'FrequencySpan', 'Full',...
    'SampleRate', rtlsdr_fs);
obj_specwaterfall = dsp.SpectrumAnalyzer(...
    'Name', 'Spectrum Analyzer Waterfall',...
    'Title', 'Spectrum Analyzer Waterfall',...
    'SpectrumType', 'Spectrogram',...
    'FrequencySpan', 'Full',...
    'SampleRate', rtlsdr_fs);

%% CALCULATIONS
rtlsdr_frmtime = rtlsdr_frmlen/rtlsdr_fs;


%% SIMULATION

% check if RTL-SDR is active
if isempty(sdrinfo(obj_rtlsdr.RadioAddress))
    error(['RTL-SDR failure. Please check connection to ',...
        'MATLAB using the "sdrinfo" command.']);
end

% reset run_time to 0 (secs)
run_time = 0;

% run while run_time is less than sim_time
while run_time < sim_time
    
    % fetch a frame from the rtlsdr
    rtlsdr_data = step(obj_rtlsdr);
    
    % update spectrum analyzer windows with new data
    step(obj_specfft, rtlsdr_data);
    step(obj_specwaterfall, rtlsdr_data);
    
    % update run_time after processing another frame
    run_time = run_time + rtlsdr_frmtime;
    
end

end

