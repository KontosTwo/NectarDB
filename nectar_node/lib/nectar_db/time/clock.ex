defmodule NectarDb.Clock do
  use Agent

  @me __MODULE__

  @type timekeeper :: fun

  @spec start_link(fun) :: {:ok, pid}
  def start_link(timekeeper) do
    Agent.start_link(fn -> timekeeper end, name: @me)
  end

  @spec get_time() :: integer
  def get_time() do
    Agent.get(@me, fn timekeeper -> timekeeper.() end)
  end
end
