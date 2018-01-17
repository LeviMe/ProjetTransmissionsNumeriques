function [bits_decodes] = Decodage(bits_codes, RS_encoding, interleaving, puncturing, convencoding)
%     RS_encoding = 1;
%     interleaving = 1;
%     puncturing = 1;
%     convencoding=1 ;
    N = 255;
    K = 239;
    S = 188;
    M = 256;
    gp = rsgenpoly(N,K,[],0);
    dec = comm.RSDecoder(N,K,gp,S);
    decoding_mode = 'hard'; %='soft'
    puncturing_matrix = [1 1 0 1];
    trellis = poly2trellis([7],[171 133]);
    
    nrows = 17; slope = 12; 
    D = nrows*(nrows-1)*slope; 
    
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
		bits_decodes = convdeintrlv(bits_decodes,nrows,slope);
        bits_decodes=bits_decodes(D+1:end);
    end
    
    if RS_encoding
        
		bits_decodes = step(dec,bits_decodes);
	end
end