defmodule NectarDb.Pinger do
  use GenServer

  @me __MODULE__

  @health_check_frequency 3000

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  @impl true
  def init(:no_args) do
    health_check()
    {:ok, nil}
  end

  @impl true
  def handle_info(:health_check, state) do
    health_check()
    {:noreply, state}
  end

  defp health_check() do
    Process.send_after(self(), :health_check, @health_check_frequency)
  end
end
