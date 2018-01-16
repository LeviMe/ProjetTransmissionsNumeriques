function [ signalBruite]= canal( dB, signal)
%CANAL simule l'ajout du bruit lors du passage du signal a travers le canal AWGN
%   Addition du bruit au signal avec le dB specifie

%Calcul de la puissance du bruit : sigma_a = 1 (variance des symboles),
%et somme du carre de h... = 1 car on a norme
%Es=2*Eb donc sigma^2 = 1./(4.*Eb/N0)
% et Eb/N0dB = 10log(Eb/N0) d'ou Eb/n0 = 10^(dB/10)
Eb_N0 = 10^(dB/10);
sigma = 1 / (2 * 10 ^ (Eb_N0 / 10));
bruit_I = sqrt(sigma) * randn(1, length(signal));
bruit_Q = sqrt(sigma) * randn(1, length(signal));
bruit = bruit_I + 1j * bruit_Q;
signalBruite = signal + bruit;

end