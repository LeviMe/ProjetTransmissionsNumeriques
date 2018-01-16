
%Le fichier codage1.m contient toutes les fonctions de codage canal et de décodage
%d'une séquence de bits prévus par l'énoncé qui sont dans l'ordre
% RS --- entrelaceur --- Convolutif ---- poinçonnage
% des variables boolèenes sont prévus pour activer ou désactiver 3 de ces 4 parties

%Spécifications de ce qui n'a pas déjà été fait:
% RS(204,188) à partir de 		comm.RSEncoder.m, comm.RSDecoder et step.m
% (des)entrelaceur sans paramètres précis de l'énoncé via  convintrlv.m et convdeintrlv.m

% La fonction poly2trellis sert à modéliser 'informatiquement' la notion
% de code convolutif et de treillis associé.
% Ses arguments sont deux matrices.
%   En notant k la taille d'un bloc d'entrée, la première est de dimension
%   k x 1. Elle donne la longueur de contrainte pour les k éléments de ce
%   bloc, i.e. dans toutes les équations régissant les valeurs de sortie,
%   qu'elle est l'ancienneté maximale du i-éme bit de ce bloc nécessaire
%   pour connaitre ces valeurs.
%   La deuxième est de dimension k*n.
%   pour n symboles de sortie à une itération, qu'elle est le bouclage via
%   un polynome sur les valeurs courante et précédente du premier symbole
%   d'entrée + à (la ligne suivante) le bouclage sur le deuxième + (à la
%   k-ième ligne) le bouclage sur le k-ième


%test bon fonctionnement. A retirer pour le rendu final même si cela figure au programme de l'enoncé
bitsI=[randi([0,1],1,10)];
trellis = poly2trellis([7],[171 133]);
encoded=convenc(bitsI,trellis);
decoded = vitdec(encoded,trellis,3,'trunc','hard');
isequal(decoded,bitsI)

% concernant le poinçonnage la fonction convenc accepte les arguments suivants
% code = convenc(msg,trellis,puncpat) d'ou la syntaxe employée.




bits=[randi([0,1],188*8,1)];


"size bits   "+int2str(size(bits))

code = Codage(bits);
"size code   " +int2str(size(code))

decode = Decodage(code);
"size decode "+int2str(size(decode))



isequal(decode, bits)
%size(decode)

function [bits_codes] = Codage(bits)
    RS_encoding = true;
    interleaving = false;
    puncturing = false;
    %paramètres du code qui suit

    decoding_mode = 'hard'; %='soft'
    puncturing_matrix = [1 1 0 1];
    trellis = poly2trellis([7],[171 133]);

    
    %Padding pour le cas général à l'entier le plus proche 
    % pour atteindre une taille totale multiple de  188*8
    
    % Je ne me suis pas occupe du dépadding !!!!!!!
%     lcmmmm=188*8;
%     taille=size(bits,2);
%     if (mod(taille,lcmmmm)~=0)
%         bits=[bits zeros(1, lcmmmm*(floor(taille/lcmmmm)+1)-taille)];
%     end
  
    
    
    N = 255;
    K = 239;
    S = 188;
    M = 256;
    gp = rsgenpoly(N,K,[],0);
    enc = comm.RSEncoder(N,K,gp,S);
    dec = comm.RSDecoder(N,K,gp,S);
   
	if RS_encoding
		% Le code RS est non-binaire, i.e. son entrée n'est pas composée de blocs de bits.
		%L'exemple du tutoriel prenait exactement le même encodeur et appliquait sur les bits la fonction bi2de(data) qui selon toute évidence signifie une conversion binaire vers décimal. data étant alors un vecteur 188 x 8 de bits aléatoire, 8=log2(M=256). Les nombres décimaux à coder étaient -me semble-t-il- la valeur de l'octet formé par chacune des colonnes de data.
		% Je dois réarranger mes données d'entrée afin de les coder selon l'énoncé c'est à dire également par bloc de 8 ; POur cela je dois:
			% 1. Trouver la fonction de ré-arrangement de matrices n*1==> n/8 * 8
			%	2. Appliquer bi2de
		% Si correction est trouvé, l'appliquer de façon identique à la fonction de décodage. Et changer le nom des variables puisque la sortie n'est alors plus composée de bits.
		%reshape(bits,[],8); 
        symboles=bi2de(reshape(bits,[],8));
		symboles_codes = step(enc,symboles);
        bits_codes = reshape(de2bi(symboles_codes),[],1);
    end
% L'entrelacement convolutif dépend de deux paramètres, la tailles des blocs à entrelacer que j'ai fixé ici à S=188 (il me semble que cette valeur soit correct) et le second appelé 'slope' dont les multiples définissent les retards de chacun des composants du bloc à coder. Je pense que son choix est arbitraire dans le cadre de ce projet, mais cela reste à verifier.

	if interleaving
		bits_codes = convintrlv(bits_codes, S,3);
    end

   % "size bits codes   "+int2str(size(bits_codes)) 
    
    if puncturing
        bits_codes = convenc(bits_codes,trellis,puncturing_matrix);
    else
        bits_codes = convenc(bits_codes,trellis);
    end

    
end

%revoir la syntaxe de l'introduction du poinçonnage dans le vitdec; je n'ai aucune certitude

function [bits_decodes] = Decodage(bits_codes)
    %paramètres du code qui suit
     RS_encoding = true;
    interleaving = false;
    puncturing = false;
    decoding_mode = 'hard'; %='soft'
    puncturing_matrix = [1 1 0 1];
    trellis = poly2trellis([7],[171 133]);

    N = 255;
    K = 239;
    S = 188;
    M = 256;
    gp = rsgenpoly(N,K,[],0);
    enc = comm.RSEncoder(N,K,gp,S);
    dec = comm.RSDecoder(N,K,gp,S);
    
	if RS_encoding
		bits_decodes = step(dec,bits_codes);
	end
	if interleaving
		bits_decodes = convdeintrlv(bits_decodes,S,3);
	end

	if puncturing
		bits_decodes = vitdec(bits_decodes,trellis,3,'trunc',decoding_mode,puncturing_matrix);
	else
		bits_decodes = vitdec(bits_decodes,trellis,3,'trunc',decoding_mode);
	end
end








