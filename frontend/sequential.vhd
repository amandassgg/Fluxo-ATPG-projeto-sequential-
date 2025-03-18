library ieee;
  use IEEE.Std_Logic_1164.All;

entity sequential is
  port (A      :  in  Std_Logic;
        B      :  in  Std_Logic;
        C      :  in  Std_Logic;
        rst  :  in  Std_Logic;
        clk    :  in  Std_Logic; 
        Q      : out Std_Logic_Vector(1 downto 0));
end sequential;


architecture FSM_a  of sequential is
  type States_Typ is (IDLE, FETCH, DECODE, EXEC);
  signal State_r : States_Typ;
  signal NextState : States_Typ;
begin
  States_Proc : process
  begin  -- process States_Proc
    wait until clk = '1';
    State_r <= NextState;   
  end process States_Proc;

  -- Compute next state
  extState_Proc : process (State_r, A, B, C, rst)
  begin  -- process extState_Proc
    NextState <= State_r; -- Default Assignment to prevent a latch
    if rst = '1' then
      NextState <= IDLE;
    else
      case State_r is
        when  IDLE =>
          if A = '1' then
            NextState <= FETCH;
          end if;

        when FETCH =>
          if C = '1' then
            NextState <= DECODE; 
          end if;

        when DECODE =>
          if C = '0' then
            NextState <= IDLE;
          else
            NextState <= EXEC; 
          end if;

        when EXEC =>
          if B = '1' then
            NextState <= FETCH;
          end if;
      end case;
    end if;
  end process extState_Proc;

  -- Mealy machine for outputs
  with State_r select
    Q <= "00" when IDLE,
         "11" when FETCH,
         "10" when EXEC,
         "01" when DECODE;
end FSM_a ;
