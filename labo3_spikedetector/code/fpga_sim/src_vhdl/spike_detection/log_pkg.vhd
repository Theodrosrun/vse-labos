-----------------------------------------------------------
-- HEIG-VD / institut REDS / TB Capitao 2015
--
-- Projet       : wire_meas
--
-- Fichier      : log_pkg.vhd
--
-- Description  : Calculs logarithme
--
-- Informations : -
--
-- Auteur       : Yann Thoma
-- Date         : -
--
--| Modifications |----------------------------------------
-- Ver  Date        Personne      Description
-- 1.0  -           Yann Thoma    Version initial
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package log_pkg is

	-- integer logarithm (rounded up) [MR version]
	function ilogup (x : natural; base : natural := 2) return natural;

	-- integer logarithm (rounded down) [MR version]
	function ilog (x : natural; base : natural := 2) return natural;

end log_pkg;

package body log_pkg is


	-- integer logarithm (rounded up) [MR version]
	function ilogup (x : natural; base : natural := 2) return natural is
	  variable y : natural := 1;
	begin
	  while x > base ** y loop
	    y := y + 1;
	  end loop;
	  return y;
	end ilogup;

	-- integer logarithm (rounded down) [MR version]
	function ilog (x : natural; base : natural := 2) return natural is
	  variable y : natural := 1;
	begin
	  while x > base ** y loop
	    y := y + 1;
	  end loop;
	  if x<base**y then
	  	y:=y-1;
	  end if;
	  return y;
	end ilog;

end log_pkg;