%1.Reading Audio File (1)
[~,Fs1] = audioread("Audio1.mp3");

%Crop to take first 18 secs
samples = [1,18*Fs1];
[y1,Fs1] = audioread("Audio1.mp3",samples);

%Information about The audio file
info1=audioinfo("Audio1.mp3");


figure(1);
%Time Domain
t1 = (0:length(y1) - 1)*18/length(y1);

subplot(2,1,1);
plot(t1,y1);
xlabel('time (sec)');
ylabel('m1(t)');

%Frequency Domain
fftSignal1 = fftshift(fft(y1));
f1 = (-1*(length(fftSignal1))/2:(length(fftSignal1)/2)-1);

subplot(2,1,2);
plot(f1, abs(fftSignal1));
xlabel('Freq (Hz)');
ylabel('M1(x)');
%BW=1.5*10^5



%1.Reading Audio File (2)
[~,Fs2] = audioread("Audio2.mp3");

%Crop to take first 18 secs
samples = [1,18*Fs2];
[y2,Fs2] = audioread("Audio2.mp3",samples);

%Information about The audio file
info2=audioinfo("Audio2.mp3");

figure(2);
%Time Domain
t2 = (0:length(y2) - 1)*18/length(y2);

subplot(2,1,1);
plot(t2,y2);
xlabel('time (sec)');
ylabel('m2(t)');

%Frequency Domain
fftSignal2 = fftshift(fft(y2));
f2 = (-1*(length(fftSignal2))/2:(length(fftSignal2)/2)-1);

subplot(2,1,2);
plot(f2, abs(fftSignal2));
xlabel('Freq (Hz)');
ylabel('M2(x)');
%BW=2*10^5


%1.Reading Audio File (3)
[~,Fs3] = audioread("Audio3.mp3");

%Crop to take first 18 secs
samples = [1,18*Fs3];
[y3,Fs3] = audioread("Audio3.mp3",samples);

%Information about The audio file
info3=audioinfo("Audio3.mp3");

figure(3);
%Time Domain
t3 = (0:length(y3) - 1)*18/length(y3);

subplot(2,1,1);
plot(t3,y3);
xlabel('time (sec)')
ylabel('m3(t)')

%Frequency Domain
fftSignal3 = fftshift(fft(y3));f3 = (-1*(length(fftSignal3))/2:(length(fftSignal3)/2)-1);

subplot(2,1,2);
plot(f3, abs(fftSignal3));
xlabel('Freq (Hz)');
ylabel('M3(x)');
%BW=1*10^5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%s(t)=x_1 (t)  cos⁡〖ω_1 t〗  +x_2 (t)  cos⁡〖ω_2 t〗+x_3 (t)  sin⁡〖ω_2 t〗
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Modulation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%(Signals with different sampling frequencies can be added, but the result is meaningless. It is best not to do it.)
%Common Sampling Freq
Fs_new = 250000;

[P, Q] = rat(Fs_new/Fs1);%Approximation
re_signal1 = resample(y1, P, Q);%Resampling to aplly low pass filter  

[P, Q] = rat(Fs_new/Fs2);
re_signal2 = resample(y2, P, Q);

[P, Q] = rat(Fs_new/Fs3);
re_signal3 = resample(y3, P, Q);

%%%%%%%%%%%%%%%%%%%Modulation Carrier%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%Frequencies%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wc1 = 2*pi*200000; %2*10^5
wc2 = 2*pi*600000;%6*10^5
%wc3 = 2*pi*600000;%6*10^5 =>no probelm due to using sine

%Time
%X-axis  values from 0-18 sec
%t = (0:length(y1) - 1)*18/length(y1);
testTimeScale1 = (0:length(re_signal1) - 1) * (1/Fs_new);
testTimeScale2 = (0:length(re_signal2) - 1) * (1/Fs_new);
testTimeScale3 = (0:length(re_signal3) - 1) * (1/Fs_new);
%Carrier Signals
carrierSignal1=transpose(cos(wc1*testTimeScale1));
carrierSignal2=transpose(cos(wc2*testTimeScale2));
carrierSignal3=transpose(sin(wc2*testTimeScale3));

%Modulated
modulated1=re_signal1.*carrierSignal1;
modulated2=re_signal2.*carrierSignal2;
modulated3=re_signal3.*carrierSignal3;
y_modulated=modulated1+modulated2+modulated3;


max_len = max(length(modulated1),max(length(modulated2),length(modulated3)));

t_ms = (0: max_len - 1) * (1 / Fs_new);
f_ms = (-max_len/2 : max_len/2 - 1) * (Fs_new / max_len);

figure(4)
subplot(2,1,1);
plot(t_ms, y_modulated);xlabel("t");ylabel("Amplitude")
title("Modulated signal")

fft_mod_s = abs(fft(y_modulated));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum of Modulated signal")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Demodulation%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2)Perform synchronous demodulation to restore the three
signal1_demodulation = y_modulated.*carrierSignal1;
LPF = lowpass(signal1_demodulation,4000,Fs_new);

figure(6)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Audio 1")

fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum of Audio 1")
audiowrite("Out1.wav", LPF, Fs_new);

signal2_demodulation = y_modulated.*carrierSignal2;
LPF = lowpass(signal2_demodulation,6000,Fs_new);
figure(7)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Audio 2")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum of Audio 2");
audiowrite("Out2.wav", LPF, Fs_new);

signal3_demodulation = y_modulated.*carrierSignal3;
LPF = lowpass(signal3_demodulation,6000,Fs_new);
figure(8)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Audio 3")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum of Audio 3")
audiowrite("Out3.wav", LPF, Fs_new);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3)Perform demodulation three times with phase shifts of 10, 30, 90 degrees for both carriers.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%For Carrier 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%10 = pi/18
carrierSignal4=transpose(cos(wc1*testTimeScale1 + pi/18));
signal1_demodulation = y_modulated.*carrierSignal4;
LPF = lowpass(signal1_demodulation,4000,Fs_new);

figure(9)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Demodulated With Pahse Shift 10 deg of wc1")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum")


%30
carrierSignal4=transpose(cos(wc1*testTimeScale1 + pi/6));
signal1_demodulation = y_modulated.*carrierSignal4;
LPF = lowpass(signal1_demodulation,4000,Fs_new);

%Attenuation occured
figure(10)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Demodulated With Pahse Shift 30 deg of wc1")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum")

%90
carrierSignal4=transpose(cos(wc1*testTimeScale1 + pi/2));
signal1_demodulation = y_modulated.*carrierSignal4;
LPF = lowpass(signal1_demodulation,4000,Fs_new);


%Signal is lost :(
figure(11)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Demodulated With Pahse Shift 90 deg of wc1")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum")
audiowrite("PhaseShift90Deg.wav", LPF, Fs_new);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%For Carrier 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%10
carrierSignal4=transpose(cos(wc2*testTimeScale2 + pi/18));
signal2_demodulation = y_modulated.*carrierSignal4;
LPF = lowpass(signal2_demodulation,6000,Fs_new);

figure(12)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Demodulated With Phase Shift 10 deg of wc2")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum of Modulated signal")


%30
carrierSignal4=transpose(cos(wc2*testTimeScale2 + pi/6));
signal2_demodulation = y_modulated.*carrierSignal4;
LPF = lowpass(signal2_demodulation,6000,Fs_new);


%Attenuation occured
figure(13)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Demodulated With Pahse Shift 30 deg of wc2")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum of Modulated signal")

%90
carrierSignal4=transpose(cos(wc2*testTimeScale2 + pi/2));
signal2_demodulation = y_modulated.*carrierSignal4;
LPF = lowpass(signal2_demodulation,6000,Fs_new);


%Audio 3 is The result of this Demodulation :)
figure(14)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Demodulated With Phase Shift 90 deg of wc2")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum")


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%For Carrier 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%10
carrierSignal4=transpose(sin(wc2*testTimeScale3 + pi/18));
signal2_demodulation = y_modulated.*carrierSignal4;
LPF = lowpass(signal2_demodulation,6000,Fs_new);



figure(15)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Demodulated With Phase Shift 10 deg of wc2")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum")


%30
carrierSignal4=transpose(sin(wc2*testTimeScale3 + pi/6));
signal2_demodulation = y_modulated.*carrierSignal4;
LPF = lowpass(signal2_demodulation,6000,Fs_new);


%Attenuation occured
figure(16)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Demodulated With Phase Shift 30 deg of wc2")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum")

%90
carrierSignal4=transpose(sin(wc2*testTimeScale3 + pi/2));
signal2_demodulation = y_modulated.*carrierSignal4;
LPF = lowpass(signal2_demodulation,6000,Fs_new);


%Audio 2 is The result of this Demodulation :)
figure(17)
subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Demodulated With Phase Shift 90 deg of wc2")
fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum")


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%For x_1 (t), perform demodulation two times with a local carrier frequency
%2HZ
wc1 = 2*pi*200000+2*pi*2; 
testTimeScale1 = (0:length(re_signal1) - 1) * (1/Fs_new);
%Carrier Signals
carrierSignal1=transpose(cos(wc1*testTimeScale1));
signal1_demodulation = y_modulated.*carrierSignal1;
LPF = lowpass(signal1_demodulation,4000,Fs_new);

%Attenuation and distortion of the output
figure(18)

subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Frequency shift by 2 Hz")

fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum")
audiowrite("FreqShift2Hz.wav", LPF, Fs_new);

%10Hz
wc1 = 2*pi*200000-2*pi*10; 
testTimeScale1 = (0:length(re_signal1) - 1) * (1/Fs_new);
%Carrier Signals
carrierSignal1=transpose(cos(wc1*testTimeScale1));
signal1_demodulation = y_modulated.*carrierSignal1;
LPF = lowpass(signal1_demodulation,4000,Fs_new);

%Attenuation and distortion of the output
figure(19)

subplot(2,1,1);
plot(t_ms, LPF);xlabel("t");ylabel("Amplitude")
title("Frequency shift by 10 Hz")

fft_mod_s = abs(fft(LPF));
subplot(2,1,2);
plot(f_ms, fftshift(fft_mod_s))
xlabel("f(Hz)");ylabel("Magnitude");title("Magnitude Spectrum")

audiowrite("FreqShift10Hz.wav", LPF, Fs_new);