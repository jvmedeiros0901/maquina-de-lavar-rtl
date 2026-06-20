entity controlador is
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
end controlador;

architecture rtl of controlador is

    type estado_t is (ESPERA, ENCHER_1, LAVAR, ESVAZIAR_1, ENCHER_2, ENXAGUAR, ESVAZIAR_2, CENTRIFUGAR);
    signal est_atual, prox_estado : estado_t := ESPERA;

begin

    -- registrador de estado (flip-flop )
    process(clk, reset)
    begin
        if reset = '1' then
            est_atual <= ESPERA;
        elsif clk'event and clk = '1' then
            est_atual <= prox_estado;
        end if;
    end process;

    -- logica do proximo estado (dataflow)
    prox_estado <=
        ENCHER_1    when (est_atual = ESPERA      and iniciar   = '1') else
        LAVAR       when (est_atual = ENCHER_1    and fim_tempo = '1') else
        ESVAZIAR_1  when (est_atual = LAVAR       and fim_tempo = '1') else
        ENCHER_2    when (est_atual = ESVAZIAR_1  and fim_tempo = '1') else
        ENXAGUAR    when (est_atual = ENCHER_2    and fim_tempo = '1') else
        ESVAZIAR_2  when (est_atual = ENXAGUAR    and fim_tempo = '1') else
        CENTRIFUGAR when (est_atual = ESVAZIAR_2  and fim_tempo = '1') else
        ESPERA      when (est_atual = CENTRIFUGAR and fim_tempo = '1') else
        est_atual;  -- senao, fica no mesmo estado

    -- ordem de carregar o tempo: vale '1' em toda transicao, menos a volta pra espera
    carregar_tempo <=
        '1' when (est_atual = ESPERA      and iniciar   = '1') else
        '1' when (est_atual = ENCHER_1    and fim_tempo = '1') else
        '1' when (est_atual = LAVAR       and fim_tempo = '1') else
        '1' when (est_atual = ESVAZIAR_1  and fim_tempo = '1') else
        '1' when (est_atual = ENCHER_2    and fim_tempo = '1') else
        '1' when (est_atual = ENXAGUAR    and fim_tempo = '1') else
        '1' when (est_atual = ESVAZIAR_2  and fim_tempo = '1') else
        '0';

    -- tempo de cada etapa
    tempo_etapa <=
        5 when (est_atual = ESPERA      and iniciar   = '1') else
        9 when (est_atual = ENCHER_1    and fim_tempo = '1') else
        4 when (est_atual = LAVAR       and fim_tempo = '1') else
        5 when (est_atual = ESVAZIAR_1  and fim_tempo = '1') else
        9 when (est_atual = ENCHER_2    and fim_tempo = '1') else
        4 when (est_atual = ENXAGUAR    and fim_tempo = '1') else
        5 when (est_atual = ESVAZIAR_2  and fim_tempo = '1') else
        0;

    -- saidas/status
    em_espera <= '1' when est_atual = ESPERA else '0';

    with est_atual select
        estado_atual <=
            0 when ESPERA,
            1 when ENCHER_1,
            2 when LAVAR,
            3 when ESVAZIAR_1,
            4 when ENCHER_2,
            5 when ENXAGUAR,
            6 when ESVAZIAR_2,
            7 when CENTRIFUGAR;

end rtl;