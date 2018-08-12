defmodule NectarAPIWeb.SucceedAfter do
  use GenServer

  @spec start_link(fun,fun,pos_integer) :: {:ok, pid}
  def start_link(fun_success,fun_fail, succeed) do
    GenServer.start_link(__MODULE__,{fun_success,fun_fail,succeed})
  end


  @impl true
  def init({fun_success,fun_fail,succeed}) do
    {:ok,{fun_success,fun_fail,succeed,0}}
  end

  @impl true
  def handle_call(:attempt,_from,{fun_succeed,fun_fail,succeed,counter}) do
    ret = if(counter >= succeed) do
      fun_succeed.()
    else
      fun_fail.()
    end
    {:reply,ret,{fun_succeed,fun_fail,succeed,counter + 1}}
  end
end