library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity configurable_counter is
    Port ( clk         : in  STD_LOGIC;
           rst         : in  STD_LOGIC;
           en          : in  STD_LOGIC;                    -- 計數開關
           up_down     : in  STD_LOGIC;                    -- '1'上數, '0'下數
           lower_bound : in  STD_LOGIC_VECTOR (3 downto 0); -- 下限
           upper_bound : in  STD_LOGIC_VECTOR (3 downto 0); -- 上限
           count_out   : out STD_LOGIC_VECTOR (3 downto 0)  -- 輸出
         );
end configurable_counter;

architecture Behavioral of configurable_counter is
    signal cnt_reg : unsigned(3 downto 0) := (others => '0');
begin
    count_out <= std_logic_vector(cnt_reg);

    process(clk, rst)
    begin
        if rst = '1' then
            cnt_reg <= unsigned(lower_bound); -- 重置時回到下限
        elsif rising_edge(clk) then
            if en = '1' then
                if up_down = '1' then
                    -- 上數邏輯：若超過上限或低於下限，回到下限
                    if cnt_reg >= unsigned(upper_bound) or cnt_reg < unsigned(lower_bound) then
                        cnt_reg <= unsigned(lower_bound);
                    else
                        cnt_reg <= cnt_reg + 1;
                    end if;
                else
                    -- 下數邏輯：若低於下限或超過上限，回到上限
                    if cnt_reg <= unsigned(lower_bound) or cnt_reg > unsigned(upper_bound) then
                        cnt_reg <= unsigned(upper_bound);
                    else
                        cnt_reg <= cnt_reg - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;