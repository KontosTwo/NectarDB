defmodule NectarAPI.Clock do
  use Agent

  @me __MODULE__

  def start_link(_args) do
    Agent.start_link(fn -> 0 end, name: @me)
  end

  def get_and_tick() do
    Agent.get_and_update(@me, fn time -> {time, time + 1} end)
  end
end