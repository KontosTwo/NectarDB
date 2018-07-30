defmodule NectarDb.Store do
  use Agent

  @me __MODULE__

  @type key :: any
  @type value :: any

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    Agent.start_link( fn -> %{} end, name: @me)
  end

  @spec store_kv(key, value) :: :ok
  def store_kv(key, value) do
    Agent.cast(@me, fn store -> Map.put(store, key, value) end)
  end

  @spec get_v(key) :: value
  def get_v(key) do
    Agent.get(@me, fn store -> Map.get(store, key) end)
  end
end