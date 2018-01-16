
bits=[randi([0,1],188*8,1)];
"size bits   "+int2str(size(bits));
code = Codage(bits);

"size code   " +int2str(size(code));
decode = Decodage(code);
"size decode "+int2str(size(decode));
isequal(decode, bits)
% [bits(1:30) decode(1:30)]

function [bits_codes] = Codage(bits)
    RS_encoding = 1;
    interleaving = 0;
    puncturing = 1;
    convencoding= 1; 
    N = 255;
    K = 239;
    S = 188;
    M = 256;
    gp = rsgenpoly(N,K,[],0);
    enc = comm.RSEncoder(N,K,gp,S);
    decoding_mode = 'hard'; %='soft'
    puncturing_matrix = [1 1 0 1];
    trellis = poly2trellis([7],[171 133]);
    
    bits_codes=bits;
    
	if RS_encoding
        symboles=bi2de(reshape(bits,[],8));
		symboles_codes = step(enc,symboles);
        bits_codes = reshape(de2bi(symboles_codes),[],1);
    end
    if interleaving
		bits_codes = convintrlv(bits_codes, 10,4);
    end

   % "size bits codes   "+int2str(size(bits_codes)) 
    
    if puncturing
        bits_codes = convenc(bits_codes,trellis,puncturing_matrix);
    else 
        if convencoding
          %  "size 1   " +int2str(size(bits_codes))
            bits_codes = convenc(bits_codes,trellis);
          %  "size 2   " +int2str(size(bits_codes))
        end
    end
    
end


function [bits_decodes] = Decodage(bits_codes)
    %paramètres du code qui suit
     RS_encoding = 1;
     interleaving = 0;
     puncturing = 1;
     convencoding=1 ;
    N = 255;
    K = 239;
    S = 188;
    M = 256;
    gp = rsgenpoly(N,K,[],0);
    dec = comm.RSDecoder(N,K,gp,S);
    decoding_mode = 'hard'; %='soft'
    puncturing_matrix = [1 1 0 1];
    trellis = poly2trellis([7],[171 133]);
 
    bits_decodes=bits_codes;
    
    if puncturing
		bits_decodes = vitdec(bits_decodes,trellis,3,'trunc',decoding_mode,puncturing_matrix);
    else
        if convencoding
           % "size 2'   " +int2str(size(bits_decodes))
            bits_decodes = vitdec(bits_decodes,trellis,3,'trunc',decoding_mode);
            %"size 1'   " +int2str(size(bits_decodes))
        end
    end
    
	if interleaving
		bits_decodes = convdeintrlv(bits_decodes,10,4);
    end
    
    if RS_encoding
        
		bits_decodes = step(dec,bits_decodes);
	end


end








