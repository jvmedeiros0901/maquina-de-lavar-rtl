entity maquina_lavar is
    port (
        iniciar           : in  bit;
        reset             : in  bit;
        clk               : in  bit;
        abrir_valvula     : out bit;
        ligar_lavar       : out bit;
        ligar_dreno       : out bit;
        ligar_centrifugar : out bit;
        display_estagio   : out bit_vector(6 downto 0);
        display_tempo     : out bit_vector(6 downto 0)
    );
end maquina_lavar;

architecture rtl of maquina_lavar is

    component controlador is
        port (
            clk            : in  bit;
            reset          : in  bit;
            iniciar        : in  bit;
            fim_tempo      : in  bit;
            carregar_tempo : out bit;
            tempo_etapa    : out integer range 0 to 15;
            em_espera      : out bit;
            estado_atual   : out integer
        );
    end component;

    component datapath is
        port (
            clk             : in  bit;
            reset           : in  bit;
            carregar_tempo  : in  bit;
            tempo_etapa     : in  integer range 0 to 15;
            em_espera       : in  bit;
            fim_tempo       : out bit;
            tempo_restante  : out integer range 0 to 15
        );
    end component;

    -- sinais internos
    signal carregar_tempo  : bit;
    signal tempo_etapa     : integer range 0 to 15;
    signal em_espera       : bit;
    signal fim_tempo       : bit;
    signal tempo_restante  : integer range 0 to 15;
    signal estado_atual    : integer;

begin

    -- instancia do controlador
    U_CTRL : controlador
        port map (
            clk            => clk,
            reset          => reset,
            iniciar        => iniciar,
            fim_tempo      => fim_tempo,
            carregar_tempo => carregar_tempo,
            tempo_etapa    => tempo_etapa,
            em_espera      => em_espera,
            estado_atual   => estado_atual
        );

    -- instancia do datapath
    U_DP : datapath
        port map (
            clk            => clk,
            reset          => reset,
            carregar_tempo => carregar_tempo,
            tempo_etapa    => tempo_etapa,
            em_espera      => em_espera,
            fim_tempo      => fim_tempo,
            tempo_restante => tempo_restante
        );

    -- aqui vai os atuadorres (logica combinacional)
    abrir_valvula     <= '1' when (estado_atual = 1 or estado_atual = 4) else '0'; -- ENCHER_1, ENCHER_2
    ligar_lavar       <= '1' when (estado_atual = 2 or estado_atual = 5) else '0'; -- LAVAR, ENXAGUAR
    ligar_dreno       <= '1' when (estado_atual = 3 or estado_atual = 6 or estado_atual = 7) else '0'; -- ESVAZIAR_1, ESVAZIAR_2, CENTRIFUGAR
    ligar_centrifugar <= '1' when (estado_atual = 7) else '0'; -- CENTRIFUGAR

    -- aqui vai os displays de estagio (lgc comb)
    display_estagio <=
        "1111110" when estado_atual = 0 else  -- '-'  ESPERA
        "0110000" when estado_atual = 1 else  -- 'E'  ENCHER_1
        "1110001" when estado_atual = 2 else  -- 'L'  LAVAR
        "1000010" when estado_atual = 3 else  -- 'd'  ESVAZIAR_1
        "0110000" when estado_atual = 4 else  -- 'E'  ENCHER_2
        "1111010" when estado_atual = 5 else  -- 'r'  ENXAGUAR usamos "r" de rinse que significa enxaguar em ingles pra n confundir com o "E" de encher
        "1000010" when estado_atual = 6 else  -- 'd'  ESVAZIAR_2 (Aqui é o dreno)
        "0110001" when estado_atual = 7 else  -- 'C'  CENTRIFUGAR
        "1111111";

    -- display do tempo (lgc comb)
    display_tempo <=
        "0000001" when tempo_restante = 0 else -- 0
        "1001111" when tempo_restante = 1 else -- 1
        "0010010" when tempo_restante = 2 else -- 2
        "0000110" when tempo_restante = 3 else -- 3
        "1001100" when tempo_restante = 4 else -- 4
        "0100100" when tempo_restante = 5 else -- 5
        "0100000" when tempo_restante = 6 else -- 6
        "0001111" when tempo_restante = 7 else -- 7
        "0000000" when tempo_restante = 8 else -- 8
        "0000100" when tempo_restante = 9 else -- 9
        "1111111";                             -- display desligado

end rtl;