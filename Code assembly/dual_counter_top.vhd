library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dual_counter_top is
    Port ( clk     : in  STD_LOGIC;
           rst     : in  STD_LOGIC;
           -- 計數器 A 控制
           en_A    : in  STD_LOGIC;
           up_A    : in  STD_LOGIC;
           low_A   : in  STD_LOGIC_VECTOR (3 downto 0);
           high_A  : in  STD_LOGIC_VECTOR (3 downto 0);
           out_A   : out STD_LOGIC_VECTOR (3 downto 0);
           -- 計數器 B 控制
           en_B    : in  STD_LOGIC;
           up_B    : in  STD_LOGIC;
           low_B   : in  STD_LOGIC_VECTOR (3 downto 0);
           high_B  : in  STD_LOGIC_VECTOR (3 downto 0);
           out_B   : out STD_LOGIC_VECTOR (3 downto 0)
         );
end dual_counter_top;

architecture Structural of dual_counter_top is
    -- 宣告子模組組件
    component configurable_counter
        port( clk, rst, en, up_down : in STD_LOGIC;
              lower_bound, upper_bound : in STD_LOGIC_VECTOR(3 downto 0);
              count_out : out STD_LOGIC_VECTOR(3 downto 0) );
    end component;
begin
    -- 實體化 A
    Counter_A: configurable_counter port map (
        clk => clk, rst => rst, en => en_A, up_down => up_A,
        lower_bound => low_A, upper_bound => high_A, count_out => out_A );

    -- 實體化 B
    Counter_B: configurable_counter port map (
        clk => clk, rst => rst, en => en_B, up_down => up_B,
        lower_bound => low_B, upper_bound => high_B, count_out => out_B );
end Structural;