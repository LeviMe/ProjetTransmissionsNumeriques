clear all; close all; clc;
warning('off', 'all');

nb_bits=15040;
N=4; % nombre d'échantillons par symbole
Te=4; % Période d'échantillonage
Ts=N*Te; % période symbole
alpha = 0.35; %alpha du filtre de mise en forme (cosinus surrelevé)

dB = 0; %bruit du canal

phi_deg = 30;           %Dephasage de la constellation (en degres)
phi = phi_deg*pi/180;   %Dephasage en radiants
ecartFreq = 0.0001;          %Ecart de frequence par rapport a Rs
BlT_dB = -3;            %Bande de bruit en dB, à faire varier entre -4 et -1
BlT = 10.^(BlT_dB);     %Bande de bruit
ordre = 2;              %Ordre du filtre de PLL

%Calculer la pente de la courbe en S du detecteur de la PLL uniquement si
%pas deja fait
try
    pente = 0;
    load pente;             %Pente de la courbe en S (calculee par le fichier fourni)
end
if pente==0
    pente = Pente(dB);
end

%Calcul des coefficients du filtre
if ordre==2
zeta=sqrt(2)/2;
A=16*zeta^2*BlT.*(1+4*zeta^2-4*BlT)/(1+4*zeta^2)./(1+4*zeta^2-8*zeta^2*BlT);
B=64*zeta^2*BlT.^2/(1+4*zeta^2)./(1+4*zeta^2-8*zeta^2*BlT);
elseif ordre==1
   B=0*BlT;
   A=4*BlT;
end
 
A=A/pente;
B=B/pente;

codagee=true;
RS_encoding = 1;
interleaving = 1;
puncturing = 0;
convencoding= 1; 

taux_d_erreurs = [];
taux_d_erreurs_scode = [];

%     bits = [randi([0,1],1,nb_bits)];
% "size bits   "+int2str(size(bits))
%     bits_code = reshape(bits, [length(bits), 1]);
%     
% 	bits_code=codage(bits_code);
% "size code   " +int2str(size(bits_code))
%     bits_code = reshape(bits_code, [1, length(bits_code)]);
%  
%     bits_decodes = reshape(bits_code, [length(bits_code), 1]);
% 	bits_decodes=Decodage(bits_decodes);
%     bits_decodes = reshape(bits_decodes, [1, length(bits_decodes)]);

for dB = 4:1:4
    %bits de base
    bits = [randi([0,1],1,nb_bits)];
    fileID = fopen('bits.dat','w');
    fprintf(fileID,'%f\n',bits);
    fclose(fileID);
    
	if (codagee) %codage utilise des vecteurs colonnes (taille,1)
        bits_code = reshape(bits, [length(bits), 1]);
		bits_code=codage(bits_code, RS_encoding, interleaving, puncturing, convencoding);
        bits_code = reshape(bits_code, [1, length(bits_code)]);
    else
        bits_code = bits;
    end
    
    symboles = 2*bits_code -1;

    %Mapping complexe
    bits_codeI = bits_code(1:2:end);
    bits_codeQ = bits_code(2:2:end);
    symbolesI = symboles(1:end/2);
    fileID = fopen('bits_codeI.dat','w');
    fprintf(fileID,'%f\n',bits_codeI);
    fclose(fileID);
    symbolesQ = symboles(end/2+1:end);
    
    %Echantillonage du filtre de mise en forme en racine
    % de cosinus surrelev� en vue de sa convolution par le signal d'entr�.
    filtre_RCS=rcosdesign(0.35,10,Te,'sqrt');
    
    suite_diracs_ponderesI=[kron(symbolesI,[1,zeros(1,Ts-1)]),zeros(1,nb_bits*Ts)];
    suite_diracs_ponderesQ=[kron(symbolesQ,[1,zeros(1,Ts-1)]),zeros(1,nb_bits*Ts)];
    signal_mis_en_formeI=filter(filtre_RCS,1,suite_diracs_ponderesI);
    signal_mis_en_formeQ=filter(filtre_RCS,1,suite_diracs_ponderesQ);
    
%     figure();
%     title("suite diracs ponderesI");
%     plot(suite_diracs_ponderesI);
%     
%     figure();
%     title("signal mis en forme I");
%     plot(signal_mis_en_formeI);
    
    signal_mis_en_forme = signal_mis_en_formeI + 1j* signal_mis_en_formeQ;
    fileID = fopen('signalFormeI.dat','w');
    fprintf(fileID,'%f\n',signal_mis_en_formeI);
    fclose(fileID);

    %ajout du bruit du canal
    signalBruite = canal(dB, signal_mis_en_forme);
    fileID = fopen('signalBruiteI.dat','w');
    fprintf(fileID,'%f\n',real(signalBruite));
    fclose(fileID);
    
%     figure()
%     title("")
%     plot(real(signalBruite));

    %Demodulation
    signal_recu = filter(filtre_RCS, 1, signalBruite);
    fileID = fopen('signalfiltreI.dat','w');
    fprintf(fileID,'%f\n',real(signal_recu));
    fclose(fileID);
%     figure()
%     title("recu")
%     plot(real(signal_recu));
    
%     signal_recuI=9/Te*filter(filtre_reception,1,signal_bruiteI);
%     signal_recuQ=9/Te*filter(filtre_reception,1,signal_bruiteQ);

    offset=Ts+Ts/2;
    prelevement=offset+Ts+1:Ts:length(bits_code)/2*(Ts)+offset+1; %points de prélevement

%     figure();
%     hold on;
%     title("signal mis en forme");
%     plot(signal_mis_en_forme);    
%     title("signal recu");
%     plot(9/Te*signal_recu,'red');
    
     %Dephasage    
     [signal_postDephase] = Dephasage(phi, ecartFreq, signal_recu);
         
     %Boucle PLL
     [signal_postPLL] = PLL(A, B, signal_postDephase);
        
    %decision par detecteur à seuil
    bits_decidesI=sign(real(signal_recu(prelevement)));
    bits_decidesQ=sign(imag(signal_recu(prelevement)));
       
    bits_decides = ([bits_decidesI, bits_decidesQ] + ones(1,length(bits_decidesI)*2)) / 2;
    
    taux_d_erreur_scode=sum(abs(bits_decides-bits_code))/length(bits_code);
    taux_d_erreurs_scode(length(taux_d_erreurs_scode)+1) = taux_d_erreur_scode;
    
    if (codagee)        
        bits_decodes = reshape(bits_decides, [length(bits_decides), 1]);
		bits_decodes=Decodage(bits_decodes, RS_encoding, interleaving, puncturing, convencoding);
        bits_decodes = reshape(bits_decodes, [1, length(bits_decodes)]);
    else
        bits_decodes = bits_decides;
    end
    fileID = fopen('bits_decodes.dat','w');
    fprintf(fileID,'%f\n',bits_decodes);
    fclose(fileID);

    taux_d_erreur=sum(abs(bits_decodes-bits))/nb_bits;
    taux_d_erreurs(length(taux_d_erreurs)+1) = taux_d_erreur;
    
%     taux_d_erreursI(length(taux_d_erreursI)+1) = taux_d_erreurI;
%     taux_d_erreursQ(length(taux_d_erreursQ)+1) = taux_d_erreurQ;
end

taux_d_erreurs
taux_d_erreurs_scode
% taux_d_erreursI
% taux_d_erreursQ
