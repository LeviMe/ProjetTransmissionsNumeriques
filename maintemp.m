clear all; close all; clc;
warning('off', 'all');

nb_bits=1024;
N=4; % nombre d'échantillons par symbole
Te=4; % Période d'échantillonage
Ts=N*Te; % période symbole
alpha = 0.35; %alpha du filtre de mise en forme (cosinus surrelevé)

%les deux listes définis ici contiendront les valeurs
% des taux d'erreurs binaires
taux_d_erreurs = [];
% taux_d_erreursI = [];
% taux_d_erreursQ = [];

codage=false;

for dB = 0:4:16

    %bits de base
    bits = [randi([0,1],1,nb_bits)];
    symboles = 2*bits -1;

	if (codage)
		bits=codage(symboles)
	end

    %Mapping complexe
    bitsI = bits(1:2:end);
    bitsQ = bits(2:2:end);
    symbolesI = symboles(1:end/2);
    symbolesQ = symboles(end/2+1:end);
    

    %Echantillonage du filtre de mise en forme en racine
    % de cosinus surrelevé en vue de sa convolution par le signal d'entrée.
    filtre_RCS=rcosdesign(0.35,10,Te,'sqrt');
    %convolution pour mise en forme.
%     suite_diracs_ponderes = [kron(bits, [1, zeros(1,Ts-1)]), zeros(1,nb_bits*Ts)];
    suite_diracs_ponderesI=[kron(symbolesI,[1,zeros(1,Ts-1)]),zeros(1,nb_bits*Ts)];
    suite_diracs_ponderesQ=[kron(symbolesQ,[1,zeros(1,Ts-1)]),zeros(1,nb_bits*Ts)];
    signal_mis_en_formeI=filter(filtre_RCS,1,suite_diracs_ponderesI);
    signal_mis_en_formeQ=filter(filtre_RCS,1,suite_diracs_ponderesQ);
    
    figure();
    title("suite diracs ponderesI");
    plot(suite_diracs_ponderesI);
    
    figure();
    title("signal mis en forme I");
    plot(signal_mis_en_formeI);
    
    signal_mis_en_forme = signal_mis_en_formeI + 1j* signal_mis_en_formeQ;
%     signal_mis_en_forme = filter(filtre_RCS, 1, suite_diracs_ponderes);

    %Modulation
    %[signal_mis_en_formeI, signal_mis_en_formeQ] = Modulation(bits, alpha, Ts, Te)

    %ajout du bruit du canal
    signalBruite = canal(dB, signal_mis_en_forme);
    
    figure()
    title("")
    plot(real(signalBruite));

    %Convolution par un filtre de reception
    filtre_reception=filtre_RCS;
    
    signal_recu = filter(filtre_reception, 1, signalBruite);
    figure()
    title("recu")
    plot(real(signal_recu));
    
    
%     signal_recuI=9/Te*filter(filtre_reception,1,signal_bruiteI);
%     signal_recuQ=9/Te*filter(filtre_reception,1,signal_bruiteQ);

    offset=Ts+Ts/2;
    A=offset+Ts+1:Ts:nb_bits/2*(Ts)+offset+1; %points de prélevement
    %size(signal_recuI)

    %Affichage de trois figures, le signal d'entrée, le signal reçu et les
    %bits correspondants aux valeurs aux instants d'échantillonage.
    figure();
    hold on;
    title("signal mis en forme");
    plot(signal_mis_en_forme);
    
    title("signal recu");
    plot(9/Te*signal_recu,'red');
    %bar(A,0.3*bits,0.01);

    %normalisation du signal detecté en vue de la comparaison avec le signal d'emission.
    signal_detecte=(1/max(signal_recu(A)))*signal_recu(A);
%     signal_detecteI=(1/max(signal_recuI(A)))*signal_recuI(A);
%     signal_detecteQ=(1/max(signal_recuQ(A)))*signal_recuQ(A);
    %decision par detecteur à seuil
%     bits_decides=sign(signal_detecte);
%     
    bits_decidesI=sign(real(signal_recu(A)));
    bits_decidesQ=sign(imag(signal_recu(A)));
       
    bits_decides = ([bits_decidesI, bits_decidesQ] + ones(1,length(bits_decidesI)*2)) / 2
    
	if (codage)
		bits_decidesI=Decodage(bits_decidesI)
		bits_decidesQ=Decodage(bits_decidesQ)
	end

    %Taux d'erreur confirmé nul en l'absence de bruit
    taux_d_erreur=sum(abs(bits_decides-bits))/nb_bits
%     taux_d_erreurI=sum(abs(bits_decidesI-bitsI))/nb_bits
%     taux_d_erreurQ=sum(abs(bits_decidesQ-bitsQ))/nb_bits
     taux_d_erreurs(length(taux_d_erreurs)+1) = taux_d_erreur;
    
%     taux_d_erreursI(length(taux_d_erreursI)+1) = taux_d_erreurI;
%     taux_d_erreursQ(length(taux_d_erreursQ)+1) = taux_d_erreurQ;
end

taux_d_erreurs
% taux_d_erreursI
% taux_d_erreursQ
