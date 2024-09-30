-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Composant    : adder
-- Description  : Additionneur de taille générique, avec report en entrée
--                et en sortie
-- Auteur       : Yann Thoma
-- Date         : 09.03.2010
-- Version      : 1.0
--
-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
generic( SIZE: integer := 8);
port(
	carryin_i: in std_logic;
	carryout_o: out std_logic;
	a_i: in std_logic_vector(SIZE-1 downto 0);
	b_i: in std_logic_vector(SIZE-1 downto 0);
	result_o: out std_logic_vector(SIZE-1 downto 0)
);
end adder;

architecture behave of adder is

	signal a_s      : unsigned(SIZE downto 0);
	signal b_s      : unsigned(SIZE downto 0);
	signal result_s : unsigned(SIZE downto 0);
	signal c_s      : unsigned(SIZE downto 0);
begin

	a_s(SIZE)            <= '0';
	a_s(SIZE-1 downto 0) <= unsigned(a_i);
	
	b_s(SIZE)            <= '0';
	b_s(SIZE-1 downto 0) <= unsigned(b_i);
	
	c_s(0)               <= carryin_i;
	c_s(SIZE downto 1)   <= (others=>'0');
	
	result_s             <= a_s + b_s + c_s;
	
	carryout_o           <= result_s(SIZE);

	result_o             <= std_logic_vector(result_s(SIZE-1 downto 0));

end behave;

