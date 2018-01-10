clear all; close all; clc;
warning('off', 'all');

nb_bits=2048;
N=4; % nombre d'échantillons par symbole
Te=64; % Période d'échantillonage
Ts=N*Te; % période symbole
alpha = 0.35; %alpha du filtre de mise en forme (cosinus surrelevé)

%les deux listes définis ici contiendront les valeurs
% des taux d'erreurs binaires
taux_d_erreursI = [];
taux_d_erreursQ = [];

codage=true;

for dB = -40:20:40

    %bits de base
    bits = 2*[randi([0,1],1,nb_bits*2)]-1;

	if (codage)
		bits=codage(bits)
	end

    %Mapping complexe
    bitsI = bits(1:2:end);
    bitsQ = bits(2:2:end);

    %Mapping complexe
    bitsI=2*[randi([0,1],1,nb_bits)]-1;
    bitsQ=2*[randi([0,1],1,nb_bits)]-1;


    %Echantillonage du filtre de mise en forme en racine
    % de cosinus surrelevé en vue de sa convolution par le signal d'entrée.
    filtre_RCS=rcosdesign(0.35,10,Te,'sqrt');
    %convolution pour mise en forme.
    suite_diracs_ponderesI=[kron(bitsI,[1,zeros(1,Ts-1)]),zeros(1,nb_bits*Ts)];
    suite_diracs_ponderesQ=[kron(bitsQ,[1,zeros(1,Ts-1)]),zeros(1,nb_bits*Ts)];
    signal_mis_en_formeI=filter(filtre_RCS,1,suite_diracs_ponderesI);
    signal_mis_en_formeQ=filter(filtre_RCS,1,suite_diracs_ponderesQ);

    %Modulation
    %[signal_mis_en_formeI, signal_mis_en_formeQ] = Modulation(bits, alpha, Ts, Te)

    %ajout du bruit du canal
    [signal_bruiteI, signal_bruiteQ] = canal(-20, signal_mis_en_formeI, signal_mis_en_formeQ);


    %Convolution par un filtre de reception
    filtre_reception=filtre_RCS;
    signal_recuI=9/Te*filter(filtre_reception,1,signal_bruiteI);
    signal_recuQ=9/Te*filter(filtre_reception,1,signal_bruiteQ);

    offset=Ts+Ts/2;
    A=offset+Ts:Ts:nb_bits*(Ts)+offset+1;
    %size(signal_recuI)

    %Affichage de trois figures, le signal d'entrée, le signal reçu et les
    %bits correspondants aux valeurs aux instants d'échantillonage.
    figure();
    hold on;
    plot(signal_mis_en_formeI(1:1:5000));
    plot(signal_recuI(1:1:5000),'red');
    %bar(A,0.3*bits,0.01);

    %normalisation du signal detecté en vue de la comparaison avec le signal d'emission.
    signal_detecteI=(1/max(signal_recuI(A)))*signal_recuI(A);
    signal_detecteQ=(1/max(signal_recuQ(A)))*signal_recuQ(A);
    %decision par detecteur à seuil
    bits_decidesI=sign(signal_detecteI);
    bits_decidesQ=sign(signal_detecteQ);

	if (codage)
		bits_decidesI=Decodage(bits_decidesI)
		bits_decidesQ=Decodage(bits_decidesQ)
	end

    %Taux d'erreur confirmé nul en l'absence de bruit
    taux_d_erreurI=sum(abs(bits_decidesI-bitsI))/nb_bits
    taux_d_erreurQ=sum(abs(bits_decidesQ-bitsQ))/nb_bits

    taux_d_erreursI(length(taux_d_erreursI)+1) = taux_d_erreurI;
    taux_d_erreursQ(length(taux_d_erreursQ)+1) = taux_d_erreurQ;
end

taux_d_erreursI
taux_d_erreursQ
