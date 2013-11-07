--
-- Copyright Technical University of Denmark. All rights reserved.
-- This file is part of the T-CREST project.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
--    1. Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
--
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the copyright holder.
--


--------------------------------------------------------------------------------
-- Communication scratch pad memory
--
-- Author: Rasmus Bo Soerensen (rasmus@rbscloud.dk)
-- Author: Evangelia Kasapaki
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.ocp.all;
use work.noc_defs.all;
use work.noc_interface.all;

entity com_spm is
  generic(
    -- 2**SPM_IDX_SIZE is the number of words in the SPM
    SPM_IDX_SIZE : natural := 10
    );
  port (
    p_clk : in std_logic;
    n_clk : in std_logic;
    reset : in std_logic;
    ocp_core_m : in ocp_core_m;
    ocp_core_s : out ocp_core_s;
    spm_m      : in spm_master;
    spm_s      : out spm_slave
  ) ;
end entity ; -- com_spm

architecture arch of com_spm is
    component bram_tdp is
        generic (
            DATA    : integer := 32;
            ADDR    : integer := 14
        );
        port (
        -- Port A
            a_clk   : in  std_logic;
            a_wr    : in  std_logic;
            a_addr  : in  std_logic_vector(ADDR-1 downto 0);
            a_din   : in  std_logic_vector(DATA-1 downto 0);
            a_dout  : out std_logic_vector(DATA-1 downto 0);

        -- Port B
            b_clk   : in  std_logic;
            b_wr    : in  std_logic;
            b_addr  : in  std_logic_vector(ADDR-1 downto 0);
            b_din   : in  std_logic_vector(DATA-1 downto 0);
            b_dout  : out std_logic_vector(DATA-1 downto 0)
        );
    end component;

    signal wr_h, wr_l : std_logic;
    signal Sdata_h, Sdata_l : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal select_low, select_low_reg : std_logic;
    signal select_high, select_high_reg : std_logic;

    signal MCmd : std_logic_vector(OCP_CMD_WIDTH-1 downto 0);

    signal h_0_en, h_1_en, h_2_en, h_3_en : std_logic;
    signal l_0_en, l_1_en, l_2_en, l_3_en : std_logic;

begin

    chip_select : process( ocp_core_m.MAddr )
    begin
        select_high <= '0';
        select_low <= '0';
        if ocp_core_m.MAddr(2) = '1' then
            select_low <= '1';
        else
            select_high <= '1';
        end if;
    end process ; -- chip_select

    wr : process( ocp_core_m.MCmd, select_high, select_low )
    begin
        wr_h <= '0';
        wr_l <= '0';
        if ocp_core_m.MCmd(0) = '1' then
            if select_high = '1' then
                wr_h <= '1';
            elsif select_low = '1' then
                wr_l <= '1';
            end if ;
        end if ;
    end process ; -- wr

    data_in_mux : process( select_high_reg, select_low_reg, SData_l, SData_h, MCmd )
    begin
        ocp_core_s.SData <= (others => '0');
        ocp_core_s.SResp <= OCP_RESP_NULL;
        if MCmd(1) = '1' then
            if select_high_reg = '1' then
                ocp_core_s.SData <= SData_h;
            elsif select_low_reg = '1' then
                ocp_core_s.SData <= SData_l;
            end if ;
            ocp_core_s.SResp <= OCP_RESP_DVA;
        end if ;

        if MCmd(0) = '1' then
            ocp_core_s.SResp <= OCP_RESP_DVA;
        end if ;
    end process ; -- data_in_mux

    MCmd_reg : process( p_clk )
    begin
        if rising_edge(p_clk) then
            if reset = '0' then
                MCmd <= ocp_core_m.MCmd  after PDELAY;
                select_low_reg <= select_low after PDELAY;
                select_high_reg <= select_high after PDELAY;
            else
                MCmd <= (others => '0');
                select_low_reg <= '0';
                select_high_reg <= '0';
            end if ;

        end if ;
    end process ; -- MCmd_reg


h_0_en <= ocp_core_m.MByteEn(0) and wr_h;
h_1_en <= ocp_core_m.MByteEn(1) and wr_h;
h_2_en <= ocp_core_m.MByteEn(2) and wr_h;
h_3_en <= ocp_core_m.MByteEn(3) and wr_h;

l_0_en <= ocp_core_m.MByteEn(0) and wr_l;
l_1_en <= ocp_core_m.MByteEn(1) and wr_l;
l_2_en <= ocp_core_m.MByteEn(2) and wr_l;
l_3_en <= ocp_core_m.MByteEn(3) and wr_l;

-- High SPM instance 0
spm_h_0 : bram_tdp
generic map (DATA=>DATA_WIDTH/4, ADDR => SPM_IDX_SIZE-1)
port map (a_clk => p_clk,
    a_wr => h_0_en,
    a_addr => ocp_core_m.MAddr(SPM_IDX_SIZE+1 downto 3),
    a_din => ocp_core_m.MData(7 downto 0),
    a_dout => SData_h(7 downto 0),
    b_clk => n_clk,
    b_wr => spm_m.MCmd(0),
    b_addr => spm_m.MAddr(SPM_IDX_SIZE-2 downto 0),
    b_din => spm_m.MData(39 downto 32),
    b_dout => spm_s.SData(39 downto 32));

-- High SPM instance 1
spm_h_1 : bram_tdp
generic map (DATA=>DATA_WIDTH/4, ADDR => SPM_IDX_SIZE-1)
port map (a_clk => p_clk,
    a_wr => h_1_en,
    a_addr => ocp_core_m.MAddr(SPM_IDX_SIZE+1 downto 3),
    a_din => ocp_core_m.MData(15 downto 8),
    a_dout => SData_h(15 downto 8),
    b_clk => n_clk,
    b_wr => spm_m.MCmd(0),
    b_addr => spm_m.MAddr(SPM_IDX_SIZE-2 downto 0),
    b_din => spm_m.MData(47 downto 40),
    b_dout => spm_s.SData(47 downto 40));

-- High SPM instance 2
spm_h_2 : bram_tdp
generic map (DATA=>DATA_WIDTH/4, ADDR => SPM_IDX_SIZE-1)
port map (a_clk => p_clk,
    a_wr => h_2_en,
    a_addr => ocp_core_m.MAddr(SPM_IDX_SIZE+1 downto 3),
    a_din => ocp_core_m.MData(23 downto 16),
    a_dout => SData_h(23 downto 16),
    b_clk => n_clk,
    b_wr => spm_m.MCmd(0),
    b_addr => spm_m.MAddr(SPM_IDX_SIZE-2 downto 0),
    b_din => spm_m.MData(55 downto 48),
    b_dout => spm_s.SData(55 downto 48));

-- High SPM instance 3
spm_h_3 : bram_tdp
generic map (DATA=>DATA_WIDTH/4, ADDR => SPM_IDX_SIZE-1)
port map (a_clk => p_clk,
    a_wr => h_3_en,
    a_addr => ocp_core_m.MAddr(SPM_IDX_SIZE+1 downto 3),
    a_din => ocp_core_m.MData(31 downto 24),
    a_dout => SData_h(31 downto 24),
    b_clk => n_clk,
    b_wr => spm_m.MCmd(0),
    b_addr => spm_m.MAddr(SPM_IDX_SIZE-2 downto 0),
    b_din => spm_m.MData(63 downto 56),
    b_dout => spm_s.SData(63 downto 56));

-- Low SPM instance 0
spm_l_0 : bram_tdp
generic map (DATA => DATA_WIDTH/4, ADDR => SPM_IDX_SIZE-1)
port map (a_clk => p_clk,
    a_wr => l_0_en,
    a_addr => ocp_core_m.MAddr(SPM_IDX_SIZE+1 downto 3),
    a_din => ocp_core_m.MData(7 downto 0),
    a_dout => SData_l(7 downto 0),
    b_clk => n_clk,
    b_wr => spm_m.MCmd(0),
    b_addr => spm_m.MAddr(SPM_IDX_SIZE-2 downto 0),
    b_din => spm_m.MData(7 downto 0),
    b_dout => spm_s.SData(7 downto 0));

-- Low SPM instance 1
spm_l_1 : bram_tdp
generic map (DATA => DATA_WIDTH/4, ADDR => SPM_IDX_SIZE-1)
port map (a_clk => p_clk,
    a_wr => l_1_en,
    a_addr => ocp_core_m.MAddr(SPM_IDX_SIZE+1 downto 3),
    a_din => ocp_core_m.MData(15 downto 8),
    a_dout => SData_l(15 downto 8),
    b_clk => n_clk,
    b_wr => spm_m.MCmd(0),
    b_addr => spm_m.MAddr(SPM_IDX_SIZE-2 downto 0),
    b_din => spm_m.MData(15 downto 8),
    b_dout => spm_s.SData(15 downto 8));

-- Low SPM instance 2
spm_l_2 : bram_tdp
generic map (DATA => DATA_WIDTH/4, ADDR => SPM_IDX_SIZE-1)
port map (a_clk => p_clk,
    a_wr => l_2_en,
    a_addr => ocp_core_m.MAddr(SPM_IDX_SIZE+1 downto 3),
    a_din => ocp_core_m.MData(23 downto 16),
    a_dout => SData_l(23 downto 16),
    b_clk => n_clk,
    b_wr => spm_m.MCmd(0),
    b_addr => spm_m.MAddr(SPM_IDX_SIZE-2 downto 0),
    b_din => spm_m.MData(23 downto 16),
    b_dout => spm_s.SData(23 downto 16));

-- Low SPM instance 3
spm_l_3 : bram_tdp
generic map (DATA => DATA_WIDTH/4, ADDR => SPM_IDX_SIZE-1)
port map (a_clk => p_clk,
    a_wr => l_3_en,
    a_addr => ocp_core_m.MAddr(SPM_IDX_SIZE+1 downto 3),
    a_din => ocp_core_m.MData(31 downto 24),
    a_dout => SData_l(31 downto 24),
    b_clk => n_clk,
    b_wr => spm_m.MCmd(0),
    b_addr => spm_m.MAddr(SPM_IDX_SIZE-2 downto 0),
    b_din => spm_m.MData(31 downto 24),
    b_dout => spm_s.SData(31 downto 24));

end architecture ; -- arch
