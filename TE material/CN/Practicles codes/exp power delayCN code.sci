// RMS Delay Spread Simulation

clc;
clear;

disp("==== RMS DELAY SPREAD SIMULATION ====");

// DISCRETE POWER DELAY PROFILE

disp("-- DISCRETE PDP --");

// Delay values in microseconds
tau_d = [0 0.5 1 1.5 2];

// Power values in dB
P_dB = [0 -3 -6 -9 -12];

// Convert dB power to linear power
P = 10.^(P_dB / 10);

// Mean Excess Delay
tau_m = sum(P .* tau_d) / sum(P);

// RMS Delay Spread
tau_rms = sqrt(sum(P .* (tau_d - tau_m).^2) / sum(P));

// Maximum Delay Spread
tau_max = max(tau_d) - min(tau_d);

// Display results
mprintf("Mean Excess Delay = %4.4f us\n", tau_m);
mprintf("RMS Delay Spread  = %4.4f us\n", tau_rms);
mprintf("Max Delay Spread  = %4.4f us\n", tau_max);

// Plot Discrete Power Delay Profile
scf(1);
clf();

plot2d3(tau_d, P_dB);

xgrid();

xlabel("Relative Delay tau (us)");
ylabel("Power (dB)");
title("Discrete Power Delay Profile");


// EXPONENTIAL POWER DELAY PROFILE

disp("-- EXPONENTIAL PDP --");

// Delay range
tau_c = linspace(0, 5, 1000);

// Parameters
P0 = 2;
tau0 = 1;

// Exponential PDP
P_c = P0 * exp(-tau_c / tau0);

// Mean Excess Delay
denominator = inttrap(tau_c, P_c);
numerator = inttrap(tau_c, tau_c .* P_c);

tau_m_c = numerator / denominator;

// RMS Delay Spread
numerator_rms = inttrap(tau_c, (tau_c - tau_m_c).^2 .* P_c);

tau_rms_c = sqrt(numerator_rms / denominator);

// Maximum Delay Spread
tau_max_c = max(tau_c) - min(tau_c);

// Display results
mprintf("Mean Excess Delay = %4.4f us\n", tau_m_c);
mprintf("RMS Delay Spread  = %4.4f us\n", tau_rms_c);
mprintf("Max Delay Spread  = %4.4f us\n", tau_max_c);

// Plot Exponential PDP
scf(2);
clf();

plot2d(tau_c, P_c);

xgrid();

xlabel("Delay (us)");
ylabel("Power");
title("Exponential Power Delay Profile");

// Set axis limits
a = gca();
a.data_bounds = [0 0; 5 2];
