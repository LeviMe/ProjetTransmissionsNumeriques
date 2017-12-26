
% Récupérer la syntaxe des fonctions nécessaires
% Télécharger le package atom pour avoir la coloration matlab qui fonctionne 
% Se concerter avec Jonathan pour avoir des informations.  
% Effacer ces lignes. 
% Tout git 

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
%   k-ième ligne) le bouclage sur le k-ième.
%

%test bon fonctionnement. A retirer pour le rendu final même si cela figure au programme
% de l'enoncé
bitsI=[randi([0,1],1,10)];
trellis = poly2trellis([7],[171 133]);
encoded=convenc(bitsI,trellis);
decoded = vitdec(encoded,trellis,3,'trunc','hard');
isequal(decoded,bitsI);

%paramètres du code qui suit
RS_encoding = false;
interleaving = false;
puncturing = false;
decoding_mode = 'hard'; %='soft'
puncturing_matrix = [1 1 0 1];
trellis = poly2trellis([7],[171 133]);


% concernant le poinçonnage la fonction convenc accepte les arguments suivants
% code = convenc(msg,trellis,puncpat) d'ou la syntaxe employée. 

function [bits_codes] = Codage(bits)
	bits_codes = bits;
	
	%if RS_encoding
	%	bits_codes = RSEncoder(bits_codes......);
	%end
	%if interleaving
	%	bits_codes = convintrlv(bits_codes.......);
	%end

	if puncturing
		bits_codes = convenc(bits_codes,trellis,puncturing_matrix);
	else
		bits_codes = convenc(bits_codes,trellis);
	end
end

%revoir la syntaxe de l'introduction du poinçonnage dans le vitdec; je n'ai aucune certitude

function [bits_decodes] = Decodage(bits_codes)
	bits_decodes = bits_codes
	
	%if RS_encoding
	%	bits_decodes = RSDEencoder(bits_decodes......);
	%end
	%if interleaving
	%	bits_decodes = convdeintrlv(bits_decodes.......);
	%end

	if puncturing
		bits_decodes = vitdec(bits_decodes,trellis,3,'trunc',decoding_mode,puncturing_matrix);
	else
		bits_decodes = vitdec(bits_decodes,trellis,3,'trunc',decoding_mode);
	end
end
 
 





