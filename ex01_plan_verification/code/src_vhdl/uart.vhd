-------------------------------------------------------------------------------
-- Projet UART
--
-- Fichier : uart_sender.vhd
-- Description: Implémentation d'un émetteur UART simple.
--
-- Auteur : Yann Thoma
-- Team   : Institut REDS
-- Date   : 19.03.13
--
--
--| Modifications |------------------------------------------------------------
-- Ver  Date      Who  Description
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart is
    generic (
        ERRNO : integer := 0;
        FIFOSIZE : integer := 8
    );
    port (
        clk_i          : in  std_logic;
        rst_i          : in  std_logic;
        clk_per_bit_i  : in  std_logic_vector(31 downto 0);
        parity_i       : in  std_logic;
        stops_i        : in  std_logic;
        send_i         : in  std_logic;
        data_in_i      : in  std_logic_vector(7 downto 0);
        sender_ready_o : out std_logic;
        data_error_o   : out std_logic;
        data_valid_o   : out std_logic;
        data_out_o     : out std_logic_vector(7 downto 0);
        rx_i           : in std_logic;
        tx_o           : out std_logic
    );
end uart;


architecture behave of uart is

    type state_type is (sInit,   -- Etat initial
                        sStart,  -- Envoi du start bit
                        sBit0,   -- Envoi du bit 0
                        sBit1,   -- Envoi du bit 1
                        sBit2,   -- Envoi du bit 2
                        sBit3,   -- Envoi du bit 3
                        sBit4,   -- Envoi du bit 4
                        sBit5,   -- Envoi du bit 5
                        sBit6,   -- Envoi du bit 6
                        sBit7,   -- Envoi du bit 7
                        sParity, -- Envoi du bit de parité
                        sStop0,  -- Envoi du 1er stop bit
                        sStop1   -- Envoi du 2eme stop bit
                        );

    signal state_s : state_type;
    signal next_state_s : state_type;

    signal counter_s : unsigned(31 downto 0);
    signal next_counter_s : unsigned(31 downto 0);

    signal data_s : std_logic_vector(7 downto 0);
    signal next_data_s : std_logic_vector(7 downto 0);

    signal parity_bit_s : std_logic;

begin

    process(data_s) is
    begin
        if (ERRNO = 1) then
            parity_bit_s <= data_s(0) xor
                            data_s(1) xor
                            '0' xor
                            data_s(3) xor
                            data_s(4) xor
                            data_s(5) xor
                            data_s(6) xor
                            data_s(7);
        elsif (ERRNO = 2) then
            parity_bit_s <= data_s(0) xor
                            data_s(1) xor
                            data_s(2) xor
                            data_s(3) xor
                            '1' xor
                            data_s(5) xor
                            data_s(6) xor
                            data_s(7);
        else
            parity_bit_s <= data_s(0) xor
                            data_s(1) xor
                            data_s(2) xor
                            data_s(3) xor
                            data_s(4) xor
                            data_s(5) xor
                            data_s(6) xor
                            data_s(7);
        end if;
    end process;

    process(clk_i,rst_i) is
    begin
        if (rst_i='1') then
            state_s   <= sInit;
            counter_s <= (others => '0');
            data_s    <= (others => '0');
        elsif rising_edge(clk_i) then
            state_s   <= next_state_s;
            counter_s <= next_counter_s;
            data_s    <= next_data_s;
        end if;
    end process;

    process(state_s,counter_s,data_s,parity_bit_s,
            clk_per_bit_i,parity_i,stops_i,send_i,data_in_i) is
    begin
        -- default values for registers
        next_state_s   <= state_s;
        next_counter_s <= counter_s;
        next_data_s    <= data_s;

        -- default values for output
        sender_ready_o        <= '0';
        tx_o           <= '1';
        case state_s is
        when sInit =>
            if (ERRNO=19) then
                sender_ready_o <= '0';
            else
                sender_ready_o <= '1';
            end if;
            next_counter_s <= unsigned(clk_per_bit_i)-1;
            if (ERRNO = 11) then
                next_counter_s <= unsigned(clk_per_bit_i)+3;
            end if;
            if (send_i='1') then
                next_data_s <= data_in_i;
                if (ERRNO = 14) then
                    next_data_s <= data_in_i(0) &
                                   data_in_i(1) &
                                   data_in_i(2) &
                                   data_in_i(3) &
                                   data_in_i(4) &
                                   data_in_i(5) &
                                   data_in_i(6) &
                                   data_in_i(7);
                end if;
                next_state_s <= sStart;
            end if;

        when sStart =>
            tx_o <= '0';
            if (ERRNO = 15) then
                if (counter_s = unsigned(clk_per_bit_i)-3) then
                    tx_o <= '1';
                end if;
            end if;
            if (counter_s = 0) or ((ERRNO = 8 ) and (counter_s = 3)) then
                next_state_s <= sBit0;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
            else
                next_counter_s <= counter_s - 1;
            end if;

        when sBit0 =>
            tx_o <= data_s(0);
            if (counter_s = 0) then
                next_state_s <= sBit1;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
            else
                next_counter_s <= counter_s - 1;
            end if;
        when sBit1 =>
            tx_o <= data_s(1);
            if (counter_s = 0) then
                next_state_s <= sBit2;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
            else
                next_counter_s <= counter_s - 1;
            end if;
        when sBit2 =>
            tx_o <= data_s(2);
            if (counter_s = 0) then
                next_state_s <= sBit3;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
            else
                next_counter_s <= counter_s - 1;
            end if;
        when sBit3 =>
            tx_o <= data_s(3);
            if (ERRNO = 16) then
                if (counter_s = unsigned(clk_per_bit_i)-3) then
                    tx_o <= not (data_s(3));
                end if;
            end if;

            if (counter_s = 0) then
                next_state_s <= sBit4;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
            else
                next_counter_s <= counter_s - 1;
            end if;
        when sBit4 =>
            tx_o <= data_s(4);
            if (counter_s = 0) then
                next_state_s <= sBit5;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
            else
                next_counter_s <= counter_s - 1;
            end if;
        when sBit5 =>
            tx_o <= data_s(5);
            if (counter_s = 0) then
                next_state_s <= sBit6;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
            else
                next_counter_s <= counter_s - 1;
            end if;
        when sBit6 =>
            tx_o <= data_s(6);
            if (counter_s = 0) then
                next_state_s <= sBit7;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
            else
                next_counter_s <= counter_s - 1;
            end if;
        when sBit7 =>
            tx_o <= data_s(7);
            if (counter_s = 0) then
                next_counter_s <= unsigned(clk_per_bit_i)-1;
                if (parity_i='1') then
                    next_state_s <= sParity;
                    if (ERRNO = 12) then
                        next_counter_s <= unsigned(clk_per_bit_i)+3;
                    end if;
                else
                    next_state_s <= sStop0;
                    if (ERRNO = 6) then
                        next_state_s <= sInit;
                    end if;
                    if (ERRNO = 13) then
                        next_counter_s <= unsigned(clk_per_bit_i)+3;
                    end if;
                end if;
                if (ERRNO = 4) then
                    next_state_s <= sParity;
                    if (ERRNO = 12) then
                        next_counter_s <= unsigned(clk_per_bit_i)+3;
                    end if;
                end if;
                if (ERRNO = 5) then
                    next_state_s <= sStop0;
                    if (ERRNO = 6) then
                        next_state_s <= sInit;
                    end if;
                    if (ERRNO = 13) then
                        next_counter_s <= unsigned(clk_per_bit_i)+3;
                    end if;
                end if;
            else
                next_counter_s <= counter_s - 1;
            end if;

        when sParity =>
            if ERRNO = 3 then
                tx_o <= not parity_bit_s;
            else
                tx_o <= parity_bit_s;
            end if;
            if (ERRNO = 17) then
                if (counter_s = unsigned(clk_per_bit_i)-3) then
                    tx_o <= not parity_bit_s;
                end if;
            end if;

            if (counter_s = 0) or ((ERRNO = 9 ) and (counter_s = 3)) then
                next_state_s <= sStop0;
                if (ERRNO = 6) then
                    next_state_s <= sInit;
                end if;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
                if (ERRNO = 13) then
                    next_counter_s <= unsigned(clk_per_bit_i)+3;
                end if;
            else
                next_counter_s <= counter_s - 1;
            end if;

        when sStop0 =>
            tx_o <= '1';
            if (counter_s = 0) or ((ERRNO = 10 ) and (counter_s = 3)) then
                if (stops_i = '1') then
                    next_state_s <= sStop1;
                else
                    next_state_s <= sInit;
                end if;
                if (ERRNO = 7) then
                    if (stops_i = '0') then
                        next_state_s <= sStop1;
                    else
                        next_state_s <= sInit;
                    end if;
                end if;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
            else
                next_counter_s <= counter_s - 1;
            end if;

        when sStop1 =>
            tx_o <= '1';
            if (ERRNO = 18) then
                if (counter_s = unsigned(clk_per_bit_i)-3) then
                    tx_o <= '0';
                end if;
            end if;

            if (counter_s = 0) then
                next_state_s <= sInit;
                next_counter_s <= unsigned(clk_per_bit_i)-1;
            else
                next_counter_s <= counter_s - 1;
            end if;

        end case;

    end process;

end behave;
