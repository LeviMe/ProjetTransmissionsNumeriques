classdef CanalClass < handle
  properties
    npts = 16
    roll_off = 0.35
    filter_size = 4
    Te = 1
    Ts
    bits
    bits_decides
    symboles
    symboles_decides
    diracs
    filtre
    Eb_N0 = 5
    signal_emis
    signal_bruite
    signal_filtre
    oeil_emission
    oeil_reception
    TEB
    dephasage = 0
    pente = 0
    structure
  end
  methods
    function obj = CanalClass()
      obj.Ts = obj.npts * obj.Te;
      obj.bits = -1;
    end
    
    function set_bits(obj, bits)
      obj.bits = bits;
      % Tester si c'est un tableau logique ou non.
      % Le convertir en un tableau normal si oui.
      if islogical(bits)
        obj.bits = double(bits);
      end
      
      % Ajouter un zéro pour avoir un nombre pair de bits si besoin
      if mod(length(obj.bits), 2) == 1
        obj.bits(end + 1) = 0;
      end
      
      % Génération des symboles
      obj.symboles = qpsk_dvbs_encode(obj.bits);

      % Génération des diracs
      surechant = zeros(1, obj.npts);
      surechant(1) = 1;
      obj.diracs = kron(obj.symboles, surechant);
    end

    function set_roll_off(obj, roll_off)
      obj.roll_off = roll_off;
    end

    function set_Eb_N0(obj, Eb_N0)
      obj.Eb_N0 = Eb_N0;
    end

    function transmettre(obj)
      if obj.bits == -1
        disp('Aucune chaîne de bits spécifiée. Utilisez Canal.set_bits pour paramétrer votre chaîne de bits.');
      else
        obj.creer_signal_emis();
        obj.creer_bruit();
        obj.dephaser();
        obj.filtrer_signal();
      end
    end  

    function creer_signal_emis(obj)
        obj.filtre = rcosdesign(obj.roll_off, obj.filter_size, obj.npts);
        obj.signal_emis = filter(obj.filtre, 1, [obj.diracs, zeros(1, obj.filter_size / 2 * obj.npts)]);
        obj.signal_emis = obj.signal_emis(obj.filter_size / 2 * obj.npts + 1:1:end);
        
        values = real(obj.signal_emis);
        values = [values zeros(1, mod((2 * obj.Ts) - mod(length(values), ( 2 * obj.Ts)), (2 * obj.Ts)))];
        obj.oeil_emission = reshape(values, [ 2 * obj.Ts length(values) / (2 * obj.Ts)]);
    end
    
    function creer_bruit(obj)
        sigma = var(real(obj.symboles)) / (2 * 10 ^ (obj.Eb_N0 / 10));
        n_I = sqrt(sigma) * randn(1, length(obj.signal_emis));

        sigma = var(real(obj.symboles)) / (2 * 10 ^ (obj.Eb_N0 / 10));
        n_Q = sqrt(sigma) * randn(1, length(obj.signal_emis));

        bruit = n_I + 1i * n_Q;

        obj.signal_bruite = obj.signal_emis + bruit;
    end

    function dephaser(obj)
      if obj.dephasage ~= 0
        obj.signal_bruite = obj.signal_bruite * exp(1j * obj.dephasage);
        if obj.pente == 0
          p = PenteClass(obj.Eb_N0);
          obj.pente = p.get_pente();
        end
        obj.structure = SynchroClass(obj.pente);
        obj.structure.set_ordre_filtre(2);
        obj.structure.set_signal(obj.signal_bruite);
        obj.structure.do();
        obj.signal_bruite = obj.structure.signal_corrige;
      end
    end
  
    function filtrer_signal(obj)
      obj.signal_filtre = filter(obj.filtre, 1, [obj.signal_bruite zeros(1, obj.filter_size / 2 * obj.npts)]);
      obj.signal_filtre = obj.signal_filtre((obj.filter_size / 2 * obj.npts) + 1:end);
      obj.symboles_decides = obj.signal_filtre(1:obj.Ts:end);
      obj.bits_decides = qpsk_dvbs_decode(obj.symboles_decides);
      
      values = real(obj.signal_filtre);
      values = [values zeros(1, mod((2 * obj.Ts) - mod(length(values), ( 2 * obj.Ts)), (2 * obj.Ts)))];
      obj.oeil_reception = reshape(values, 2 * obj.Ts, length(values) / (2 * obj.Ts));
      [n, TEB] = biterr(obj.bits, obj.bits_decides);
      obj.TEB = TEB;
    end

    function set_dephasage(obj, deg)
      obj.dephasage = deg * pi / 180;
      obj.pente = 0;
    end

  end
end
