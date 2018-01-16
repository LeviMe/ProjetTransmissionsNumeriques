function [bits_codes] = codage(bits)
    print = "hello world"
% 	bits_codes = bits;
%     RS_encoding
% 	if RS_encoding
% 		% Le code RS est non-binaire, i.e. son entrée n'est pas composée de blocs de bits.
% 		%L'exemple du tutoriel prenait exactement le même encodeur et appliquait sur les bits la fonction bi2de(data) qui selon toute évidence signifie une conversion binaire vers décimal. data étant alors un vecteur 188 x 8 de bits aléatoire, 8=log2(M=256). Les nombres décimaux à coder étaient -me semble-t-il- la valeur de l'octet formé par chacune des colonnes de data.
% 		% Je dois réarranger mes données d'entrée afin de les coder selon l'énoncé c'est à dire également par bloc de 8 ; POur cela je dois:
% 			% 1. Trouver la fonction de ré-arrangement de matrices n*1==> n/8 * 8
% 			%	2. Appliquer bi2de
% 		% Si correction est trouvé, l'appliquer de façon identique à la fonction de décodage. Et changer le nom des variables puisque la sortie n'est alors plus composée de bits.
% 		symboles=bi2de(reshape(bits,8,[]));
% 		%<==> bi2de(reshape(bits,[8,size(bits)/8]));
% 		bits_codes = step(enc,symboles);
% 	end
% % L'entrelacement convolutif dépend de deux paramètres, la tailles des blocs à entrelacer que j'ai fixé ici à S=188 (il me semble que cette valeur soit correct) et le second appelé 'slope' dont les multiples définissent les retards de chacun des composants du bloc à coder. Je pense que son choix est arbitraire dans le cadre de ce projet, mais cela reste à verifier.
% 
% 	if interleaving
% 		bits_codes = convintrlv(bits_codes, S,3);
% 	end
% 
% 	if puncturing
% 		bits_codes = convenc(bits_codes,trellis,puncturing_matrix);
% 	else
% 		bits_codes = convenc(bits_codes,trellis);
% 	end
end

