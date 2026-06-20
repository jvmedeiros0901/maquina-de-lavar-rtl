entity datapath is
    port (
        clk             : in  bit;
        reset           : in  bit;
        carregar_tempo  : in  bit;
        tempo_etapa     : in  integer range 0 to 15;
        em_espera       : in  bit;
        fim_tempo       : out bit;
        tempo_restante  : out integer range 0 to 15
    );
end datapath;

architecture rtl of datapath is

    signal tempo_reg      : integer range 0 to 15 := 0;
    signal contador_clock : integer := 0;
    signal pulso1s        : bit := '0';

    constant limite1s : integer := 5;

begin

    -- divisor de clock(contador)
    process(clk, reset)
    begin
        if reset = '1' then
            contador_clock <= 0;
            pulso1s <= '0';
        elsif clk'event and clk = '1' then
            if contador_clock = (limite1s - 1) then
                contador_clock <= 0;
                pulso1s <= '1';
            else
                contador_clock <= contador_clock + 1;
                pulso1s <= '0';
            end if;
        end if;
    end process;

    -- contador regressivo de tempo (registrador + contador)
    process(clk, reset)
    begin
        if reset = '1' then
            tempo_reg <= 0;
        elsif clk'event and clk = '1' then
            if carregar_tempo = '1' then
                tempo_reg <= tempo_etapa; -- carrega o tempo da etapa
            elsif pulso1s = '1' and tempo_reg > 0 then
                tempo_reg <= tempo_reg - 1; -- diminui 1 a cada segundo
            end if;
        end if;
    end process;

    -- saídas (logica combinacional)
    tempo_restante <= tempo_reg;
    fim_tempo      <= '1' when (tempo_reg = 0 and em_espera = '0') else '0';

end rtl;