--------------------------------------------------------------------------------
--
-- fichier:		OneCtr_tb.vhd
-- créateur:	Yann Thoma
--				yann.thoma@hesge.ch
-- date:		Janvier 2006
--
-- description:	banc de test du compteur de 1s
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity OneCtr_tb is
end OneCtr_tb;

architecture comp of OneCtr_tb is

	-- période d'horloge
	constant CLK_PERIOD: time:=80 ns;

	-- composant à tester
	component OneCtr
	port(
			clk: in std_logic;
			start: in std_logic;
			InPort: in std_logic_vector(63 downto 0);
			OutPort: out std_logic_vector(6 downto 0)
	);
	end component;

	-- configuration
	for ctr: OneCtr use entity work.OneCtr(proc);
	for ctr1: OneCtr use entity work.OneCtr(combinatorial);
	for ctr2: OneCtr use entity work.OneCtr(pipeline);
	for ctr3: OneCtr use entity work.OneCtr(oneadder);
	for ctr4: OneCtr use entity work.OneCtr(PISO);
	for ctr5: OneCtr use entity work.OneCtr(Mux);

	-- signaux à connecter au composant
	signal clk,rst,start: std_logic;
	signal InPort: std_logic_vector(63 downto 0);
	signal OutPort: std_logic_vector(6 downto 0);
	signal OutPort1: std_logic_vector(6 downto 0);
	signal OutPort2: std_logic_vector(6 downto 0);
	signal OutPort3: std_logic_vector(6 downto 0);
	signal OutPort4: std_logic_vector(6 downto 0);
	signal OutPort5: std_logic_vector(6 downto 0);

	-- compteur de nombre de coups d'horloge
	signal count: integer:=0;

begin

	ctr: OneCtr
	port map(	clk=>clk,start=>start,InPort=>InPort,OutPort=>OutPort);
	
	ctr1: OneCtr
	port map(	clk=>clk,start=>start,InPort=>InPort,OutPort=>OutPort1);
	
	ctr2: OneCtr
	port map(	clk=>clk,start=>start,InPort=>InPort,OutPort=>OutPort2);
	
	ctr3: OneCtr
	port map(	clk=>clk,start=>start,InPort=>InPort,OutPort=>OutPort3);
	
	ctr4: OneCtr
	port map(	clk=>clk,start=>start,InPort=>InPort,OutPort=>OutPort4);
	
	ctr5: OneCtr
	port map(	clk=>clk,start=>start,InPort=>InPort,OutPort=>OutPort5);

	-- génération de l'horloge
	process
	begin
		clk<='0';
		wait for CLK_PERIOD/2;
		clk<='1';
		wait for CLK_PERIOD/2;
	end process;
	
	-- génération du reset
	process
	begin
		start<='0';
		wait for CLK_PERIOD;
		start<='1';
		wait for CLK_PERIOD;
		start<='0';
		wait;
	end process;
	
	-- compteur qui s'incrémente depuis le start, pour compter le temps de
	-- traitement
	process(clk)
	begin
		if start='1' then
			count<=0;
		else
			count<=count+1;
		end if;
	end process;
	
	-- On force les entrées. Nombre de 1: 13
	InPort<=X"8070605040302010";
	
end comp;
		