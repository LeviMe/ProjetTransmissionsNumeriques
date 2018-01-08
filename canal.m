function [signalBruiteI, signalBruiteQ] = canal(dB, signalI, signalQ)
    sigma = sqrt(1./(4.*10.^(dB/10)));
    signalBruiteI = signalI + sigma.*rand(1, length(signalI));
    signalBruiteQ = signalQ + sigma.*rand(1, length(signalQ));
end