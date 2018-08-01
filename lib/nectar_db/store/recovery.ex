defmodule NectarDb.Recovery do
  use GenServer

  @me __MODULE__

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  @impl true
  def init(:no_args) do
    Process.send_after(self(), :recovery, 0)
    {:ok, nil}
  end

  @impl true
  def handle_info(:recovery, state) do
    
    {:noreply,state}
  end
end
