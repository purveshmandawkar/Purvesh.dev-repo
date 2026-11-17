
clc;
clear;
close;

// General Parameters
fc = 3.5e9;
c = 3e8;
v = 30;
fd = v*fc/c;

Fs = 10000;
Tsim = 0.2;
t = 0:1/Fs:Tsim-1/Fs;
Nt = length(t);
Nfft = 2048;
f_axis = (-Nfft/2:Nfft/2-1)*(Fs/Nfft);

// TDL Channel
tdl_delay_us = [0 0.1 0.3 0.5 0.8 1.2];
tdl_power_dB = [0 -2 -5 -8 -12 -16];

tdl_delay = tdl_delay_us*1e-6;
tdl_power = 10.^(tdl_power_dB/10);
tdl_power = tdl_power/sum(tdl_power);
K_tdl = length(tdl_delay);

h_tdl = zeros(K_tdl,Nt);

for k = 1:K_tdl
    h_tdl(k,:) = sqrt(tdl_power(k))* ...
        (grand(1,Nt,"nor",0,1) + ...
        %i*grand(1,Nt,"nor",0,1))/sqrt(2);
end

tdl_pdp = mean(abs(h_tdl).^2,2);

scf(1);
bar(tdl_delay_us,10*log10(tdl_pdp));
xlabel("Delay (us)");
ylabel("Power (dB)");
title("TDL Power Delay Profile");
xgrid();

scf(2);
plot(t*1000,abs(h_tdl(1,:)));
xlabel("Time (ms)");
ylabel("|h(t)|");
title("TDL Time Response");
xgrid();

// TDL Frequency Response
h_impulse = zeros(1,Nfft);

for k = 1:K_tdl
    d = round(tdl_delay(k)*Fs)+1;
    if d <= Nfft then
        h_impulse(d) = sqrt(tdl_power(k));
    end
end

H_tdl = fftshift(fft(h_impulse,Nfft));

scf(3);
plot(f_axis/1e3,20*log10(abs(H_tdl)+1e-12));
xlabel("Frequency (kHz)");
ylabel("Magnitude (dB)");
title("TDL Frequency Response");
xgrid();

// Representative CDL Channel
cdl_delay_us = [0 0.05 0.12 0.25 0.35 0.55 0.75 1.0 1.4];
cdl_power_dB = [0 -1 -2 -4 -5 -8 -10 -13 -16];

cdl_delay = cdl_delay_us*1e-6;
cdl_power = 10.^(cdl_power_dB/10);
cdl_power = cdl_power/sum(cdl_power);
K_cdl = length(cdl_delay);

h_cdl = zeros(K_cdl,Nt);

for k = 1:K_cdl
    h_cdl(k,:) = sqrt(cdl_power(k))* ...
        (grand(1,Nt,"nor",0,1) + ...
        %i*grand(1,Nt,"nor",0,1))/sqrt(2);
end

cdl_pdp = mean(abs(h_cdl).^2,2);

scf(4);
bar(cdl_delay_us,10*log10(cdl_pdp));
xlabel("Delay (us)");
ylabel("Power (dB)");
title("CDL Power Delay Profile");
xgrid();

scf(5);
plot(t*1000,abs(h_cdl(1,:)));
xlabel("Time (ms)");
ylabel("|h(t)|");
title("CDL Time Response");
xgrid();

// CDL Frequency Response
h_cdl_impulse = zeros(1,Nfft);

for k = 1:K_cdl
    d = round(cdl_delay(k)*Fs)+1;
    if d <= Nfft then
        h_cdl_impulse(d) = sqrt(cdl_power(k));
    end
end

H_cdl = fftshift(fft(h_cdl_impulse,Nfft));

scf(6);
plot(f_axis/1e3,20*log10(abs(H_cdl)+1e-12));
xlabel("Frequency (kHz)");
ylabel("Magnitude (dB)");
title("CDL Frequency Response");
xgrid();

// Compare TDL and CDL
scf(7);
plot(f_axis/1e3,20*log10(abs(H_tdl)+1e-12));
plot(f_axis/1e3,20*log10(abs(H_cdl)+1e-12));
xlabel("Frequency (kHz)");
ylabel("Magnitude (dB)");
title("TDL vs CDL");
legend(["TDL";"CDL"]);
xgrid();

// Antenna Configuration
antennas = [1 2 4];

disp("Antenna Configuration: Tx x Rx");
for k = 1:length(antennas)
    disp(string(antennas(k))+" x "+string(antennas(k)));
    disp("Spatial Channels: "+string(antennas(k)^2));
end

// Doppler Study
velocity = [0 10 30 60];
disp("Doppler Frequency (Hz):");
disp(velocity*fc/c);

// RMS Delay Spread
P = tdl_power;
mean_delay = sum(P.*tdl_delay);
rms_delay = sqrt(sum(P.*tdl_delay.^2)-mean_delay^2);

disp("Carrier Frequency (GHz):");
disp(fc/1e9);
disp("Maximum Doppler (Hz):");
disp(fd);
disp("TDL RMS Delay Spread (us):");
disp(rms_delay*1e6);
disp("TDL Taps:");
disp(K_tdl);
disp("CDL Components:");
disp(K_cdl);
disp("Simulation Completed");

