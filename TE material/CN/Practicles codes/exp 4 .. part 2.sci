clc;
clear;
close;

// =====================================================
// Cellular Network Laboratory
// Experiment: BER Performance of Multi-Antenna
// Rayleigh Fading Channel
//
// Modulation       : BPSK
// Channel          : Rayleigh Fading + AWGN
// Antenna System   : 1 x 2 SIMO
// Combining        : Maximum Ratio Combining (MRC)
// SNR              : 0 to 60 dB
// Software         : Scilab
// =====================================================

// -----------------------------------------------------
// 1. Simulation Parameters
// -----------------------------------------------------

N = 100000;              // Number of transmitted bits
SNR_dB = 0:5:60;         // SNR range
Nr = 2;                  // Number of receive antennas

BER_SISO = zeros(1,length(SNR_dB));
BER_MRC  = zeros(1,length(SNR_dB));

// -----------------------------------------------------
// 2. Generate Random Binary Data
// -----------------------------------------------------

bits = grand(1,N,"uin",0,1);

// -----------------------------------------------------
// 3. BPSK Modulation
// 0 -> +1
// 1 -> -1
// -----------------------------------------------------

x = 1 - 2*bits;

// -----------------------------------------------------
// 4. Loop for Different SNR Values
// -----------------------------------------------------

for snr_index = 1:length(SNR_dB)

    snr = SNR_dB(snr_index);

    // Convert SNR from dB to linear scale
    snr_linear = 10^(snr/10);

    // Noise standard deviation
    sigma = sqrt(1/(2*snr_linear));

    // -------------------------------------------------
    // SISO Reference: 1 Transmit x 1 Receive
    // -------------------------------------------------

    // Generate Rayleigh fading coefficient
    h1 = (grand(1,N,"nor",0,1) ...
        + %i*grand(1,N,"nor",0,1))/sqrt(2);

    // Generate complex AWGN
    n1 = sigma * (grand(1,N,"nor",0,1) ...
        + %i*grand(1,N,"nor",0,1));

    // Received signal
    y1 = h1 .* x + n1;

    // Equalization
    z1 = y1 ./ h1;

    // BPSK detection
    detected1 = zeros(1,N);

    for k = 1:N
        if real(z1(k)) < 0 then
            detected1(k) = 1;
        else
            detected1(k) = 0;
        end
    end

    // Calculate SISO BER
    error_bits = sum(bits <> detected1);

    BER_SISO(snr_index) = error_bits/N;


    // -------------------------------------------------
    // 5. Two-Branch Receive Diversity (1 x 2)
    // -------------------------------------------------

    // Rayleigh fading channel coefficients
    h1 = (grand(1,N,"nor",0,1) ...
        + %i*grand(1,N,"nor",0,1))/sqrt(2);

    h2 = (grand(1,N,"nor",0,1) ...
        + %i*grand(1,N,"nor",0,1))/sqrt(2);

    // AWGN for Receiver 1
    n1 = sigma * (grand(1,N,"nor",0,1) ...
        + %i*grand(1,N,"nor",0,1));

    // AWGN for Receiver 2
    n2 = sigma * (grand(1,N,"nor",0,1) ...
        + %i*grand(1,N,"nor",0,1));

    // -------------------------------------------------
    // Received signals
    // -------------------------------------------------

    y1 = h1 .* x + n1;
    y2 = h2 .* x + n2;

    // -------------------------------------------------
    // Maximum Ratio Combining (MRC)
    // -------------------------------------------------

    y_combined = conj(h1).*y1 + conj(h2).*y2;

    // -------------------------------------------------
    // BPSK Detection
    // -------------------------------------------------

    detected_mrc = zeros(1,N);

    for k = 1:N

        if real(y_combined(k)) < 0 then
            detected_mrc(k) = 1;
        else
            detected_mrc(k) = 0;
        end

    end

    // -------------------------------------------------
    // Calculate BER
    // -------------------------------------------------

    error_bits_mrc = sum(bits <> detected_mrc);

    BER_MRC(snr_index) = error_bits_mrc/N;

end


// -----------------------------------------------------
// 6. Display BER Results
// -----------------------------------------------------

disp("===============================================");
disp("       BER SIMULATION RESULTS");
disp("===============================================");

disp("SNR (dB):");
disp(SNR_dB);

disp("SISO BER:");
disp(BER_SISO);

disp("1 x 2 MRC BER:");
disp(BER_MRC);


// -----------------------------------------------------
// 7. Plot BER vs SNR
// -----------------------------------------------------

scf(1);

plot(SNR_dB, BER_SISO, "o-");
plot(SNR_dB, BER_MRC, "s-");

xgrid();

xlabel("SNR (dB)");
ylabel("Bit Error Rate (BER)");

title("BER Performance of Rayleigh Fading Channel");

legend(["SISO (1x1)"; "1x2 MRC Diversity"]);


// -----------------------------------------------------
// 8. BER Plot with Logarithmic Y-Axis
// -----------------------------------------------------

scf(2);

plot2d("nl", SNR_dB, BER_SISO);
plot2d("nl", SNR_dB, BER_MRC);

xgrid();

xlabel("SNR (dB)");
ylabel("BER");

title("BER vs SNR for Rayleigh Fading Channel");

legend(["SISO (1x1)"; "1x2 MRC"]);
