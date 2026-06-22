library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_dual_counter is
end tb_dual_counter;

architecture Behavior of tb_dual_counter is 
    component dual_counter_top
    port( clk, rst, en_A, up_A, en_B, up_B : in std_logic;
          low_A, high_A, low_B, high_B : in std_logic_vector(3 downto 0);
          out_A, out_B : out std_logic_vector(3 downto 0) );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal en_A, up_A : std_logic := '0';
    signal en_B, up_B : std_logic := '0';
    signal low_A : std_logic_vector(3 downto 0) := "0000"; -- 0
    signal high_A : std_logic_vector(3 downto 0) := "1001";-- 9
    signal low_B : std_logic_vector(3 downto 0) := "0011"; -- 3
    signal high_B : std_logic_vector(3 downto 0) := "1100";-- 12
    signal out_A, out_B : std_logic_vector(3 downto 0);

begin
    uut: dual_counter_top port map ( clk=>clk, rst=>rst, en_A=>en_A, up_A=>up_A, 
                                     low_A=>low_A, high_A=>high_A, out_A=>out_A,
                                     en_B=>en_B, up_B=>up_B, low_B=>low_B, high_B=>high_B, out_B=>out_B );

    clk <= not clk after 5 ns; -- 產生 10ns 週期時脈

    stim_proc: process
    begin		
        rst <= '1'; wait for 20 ns; rst <= '0';
        
        -- ? 開始測試
        en_A <= '1'; up_A <= '0'; -- A 進行 0-9 上數
        en_B <= '1'; up_B <= '1'; -- B 進行 12-3 下數
        
        wait for 300 ns;
        
        -- ? 動態改 A 的範圍變成 2 到 5
        low_A <= "0010"; high_A <= "0101";
        
        wait;
    end process;
end Behavior;