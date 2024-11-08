--------------------------------------------------------------------------------
--
-- file:   rom.vhd
-- author: Yann Thoma
--         yann.thoma@hesge.ch
-- date:   January 2006
--
-- description: ROM storing the executed program by the control unit
--              of the 1s counter
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    generic(N: integer := 8);
    port(
        addr: in std_logic_vector(N-1 downto 0);
        data: out std_logic_vector(30+N-1 downto 0)
    );
end rom;

architecture comp of rom is
    -- Constant declaration

    -- Input mux for the register bank
    constant ctrl: std_logic_vector(3 downto 0) := "0000";
    constant in0:  std_logic_vector(3 downto 0) := "0001";
    constant in1:  std_logic_vector(3 downto 0) := "0010";
    constant in2:  std_logic_vector(3 downto 0) := "0011";
    constant in3:  std_logic_vector(3 downto 0) := "0100";
    constant in4:  std_logic_vector(3 downto 0) := "0101";
    constant in5:  std_logic_vector(3 downto 0) := "0110";
    constant in6:  std_logic_vector(3 downto 0) := "0111";
    constant in7:  std_logic_vector(3 downto 0) := "1000";
    constant alu:  std_logic_vector(3 downto 0) := "1001";

    -- Regsiters addresses
    constant result: std_logic_vector(3 downto 0) := "0000";
    constant mask:   std_logic_vector(3 downto 0) := "0001";
    constant data0:  std_logic_vector(3 downto 0) := "0010";
    constant data1:  std_logic_vector(3 downto 0) := "0011";
    constant data2:  std_logic_vector(3 downto 0) := "0100";
    constant data3:  std_logic_vector(3 downto 0) := "0101";
    constant data4:  std_logic_vector(3 downto 0) := "0110";
    constant data5:  std_logic_vector(3 downto 0) := "0111";
    constant data6:  std_logic_vector(3 downto 0) := "1000";
    constant data7:  std_logic_vector(3 downto 0) := "1001";
    constant count:  std_logic_vector(3 downto 0) := "1010";
    constant tmp:    std_logic_vector(3 downto 0) := "1011";
    constant zero:   std_logic_vector(3 downto 0) := "1100";
    constant one:    std_logic_vector(3 downto 0) := "1101";
    constant eight:  std_logic_vector(3 downto 0) := "1110";
    constant nocare: std_logic_vector(3 downto 0) := "0000";

    -- ALU operation
    constant add:  std_logic_vector(2 downto 0) := "000";
    constant shr:  std_logic_vector(2 downto 0) := "001";
    constant eq:   std_logic_vector(2 downto 0) := "010";
    constant and2: std_logic_vector(2 downto 0) := "011";
    constant mov:  std_logic_vector(2 downto 0) := "100";
    constant noop: std_logic_vector(2 downto 0) := "000";

    -- CTRL values
    constant zero8:  std_logic_vector(7 downto 0) := "00000000";
    constant one8:   std_logic_vector(7 downto 0) := "00000001";
    constant eight8: std_logic_vector(7 downto 0) := "00001000";
    constant noctrl: std_logic_vector(7 downto 0) := "00000000";

    constant loopbegin: std_logic_vector(N-1 downto 0) := "00001101";
    constant loopout:   std_logic_vector(N-1 downto 0) := "00101001";
    constant noaddr:    std_logic_vector(N-1 downto 0) := (others => '0');

    -- Jumps
    constant jp:   std_logic := '1';
    constant nojp: std_logic := '0';
    constant jf:   std_logic := '1';
    constant nojf: std_logic := '0';

    -- Register Write enable
    constant wen: std_logic := '1';
    constant now: std_logic := '0';

    -- ROM size
    constant MEMSIZE: integer := 42;
    -- Type for ROM data
    type mem_type is array(0 to MEMSIZE-1) of std_logic_vector(30+N-1 downto 0);

    -- ROM declaration
    constant mem: mem_type :=(
        -- Register loading
        noaddr&	nojp&	nojf&	zero8&	ctrl&	wen&	result&	nocare&	nocare&	noop,
        noaddr&	nojp&	nojf&	one8&	ctrl&	wen&	mask&	nocare& nocare& noop,
        noaddr&	nojp&	nojf&	zero8&	ctrl&	wen&	count&	nocare& nocare& noop,
        noaddr&	nojp&	nojf&	one8&	ctrl&	wen&	one&	nocare& nocare& noop,
        noaddr&	nojp&	nojf&	eight8&	ctrl&	wen&	eight&	nocare& nocare& noop,
        noaddr&	nojp&	nojf&	noctrl&	in0&	wen&	data0&	nocare&	nocare& noop,
        noaddr&	nojp&	nojf&	noctrl&	in1&	wen&	data1&	nocare&	nocare& noop,
        noaddr&	nojp&	nojf&	noctrl&	in2&	wen&	data2&	nocare&	nocare& noop,
        noaddr&	nojp&	nojf&	noctrl&	in3&	wen&	data3&	nocare&	nocare& noop,
        noaddr&	nojp&	nojf&	noctrl&	in4&	wen&	data4&	nocare&	nocare& noop,
        noaddr&	nojp&	nojf&	noctrl&	in5&	wen&	data5&	nocare&	nocare& noop,
        noaddr&	nojp&	nojf&	noctrl&	in6&	wen&	data6&	nocare&	nocare& noop,
        noaddr&	nojp&	nojf&	noctrl&	in7&	wen&	data7&	nocare&	nocare& noop,
        -- Loop start: loopbegin
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	tmp&	data0&	mask&	and2,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	result&	result&	tmp&	add,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	data0&	data0&	nocare&	shr,

        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	tmp&	data1&	mask&	and2,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	result&	result&	tmp&	add,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	data1&	data1&	nocare&	shr,

        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	tmp&	data2&	mask&	and2,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	result&	result&	tmp&	add,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	data2&	data2&	nocare&	shr,

        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	tmp&	data3&	mask&	and2,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	result&	result&	tmp&	add,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	data3&	data3&	nocare&	shr,

        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	tmp&	data4&	mask&	and2,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	result&	result&	tmp&	add,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	data4&	data4&	nocare&	shr,

        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	tmp&	data5&	mask&	and2,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	result&	result&	tmp&	add,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	data5&	data5&	nocare&	shr,

        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	tmp&	data6&	mask&	and2,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	result&	result&	tmp&	add,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	data6&	data6&	nocare&	shr,

        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	tmp&	data7&	mask&	and2,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	result&	result&	tmp&	add,
        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	data7&	data7&	nocare&	shr,

        noaddr&	nojp&	nojf&	noctrl&	alu&	wen&	count&	count&	one&	add,
        noaddr&	nojp&	nojf&	noctrl&	alu&	now&	nocare&	count&	eight&	eq,
        loopout&nojp&	jf&		noctrl& alu&	now&	nocare&	nocare&	nocare&	noop,
        loopbegin&jp&	nojf&	noctrl& alu&	now&	nocare&	nocare&	nocare& noop,
        -- loopout
        loopout&jp&		nojf&	noctrl&	alu&	now&	nocare&	result&	nocare&	mov
    );

begin

    -- Output directy depend from the address
    data <= mem(to_integer(unsigned(addr)));

end comp;
