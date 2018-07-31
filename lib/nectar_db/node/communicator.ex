defmodule NectarDb.Communicator do
  use Agent

  @me __MODULE__

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    Agent.start_link(fn -> [] end, name: @me)
  end

  @spec add_node(String.t()) :: :ok
  def add_node(node) do
    Node.connect String.to_atom(node)    
    Agent.cast(@me, fn nodes -> [node | nodes] end)
  end

  @spec get_nodes() :: [String.t()]
  def get_nodes() do
    Agent.get(@me, fn nodes -> nodes end)
  end
end
