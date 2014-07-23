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
-- Definitions package
--
-- Author: Evangelia Kasapaki
-- Author: Rasmus Bo Soerensen
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.config_types.all;

package config is
	constant SPM_ADDR_WIDTH	: integer := 9;
  
    
    
    
    constant TARGET_ARCHITECTURE : ARCHITECTURES := RTL;
    constant TARGET_IMPLEMENTATION : IMPLEMENTATIONS := ASYNC;
    constant GATING_ENABLED : integer := 1;

    constant N : integer := 4; -- Horizontal width
    constant M : integer := 4; -- Vertical Height
    
    constant NODES : integer := N*M;
    constant PRD_LENGTH : integer := 23;

    constant SWAP_PORTS : boolean := false;
    
    constant LINK_PIPELINE_STAGES : integer := 0;
    constant LINK_PIPELINE_INIT	: latch_state_vector(3 downto 0) := (EMPTY_BUBBLE, EMPTY_TOKEN, VALID_BUBBLE, VALID_TOKEN);
    
    constant TEST_TILED_4x4_DIR : string := "../test/testcases/test_tiled_4x4/";
    constant TG_SCHEDULE_FILE : string := TEST_TILED_4x4_DIR & "all_to_all.sched";
    constant TG_SPM_INIT_FILE : string := TEST_TILED_4x4_DIR & "SPM_init.dat";
    constant TG_DMA_INIT_FILE : string := TEST_TILED_4x4_DIR & "DMA_init.dat";
    
    -- simulation delays
    constant PDELAY		: time := 500 ps;
    constant NA_HPERIOD	: time := 5 ns;
    constant P_HPERIOD	: time := 5 ns;
    constant SKEW           : time := 0 ns;
    constant delay : time := 0.3 ns;
    
end package ; -- aegean_def


