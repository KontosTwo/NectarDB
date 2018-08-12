defmodule NectarAPI.Router.Nodes do
  use Agent

  alias NectarAPI.Util.Queue

  @type node_name :: String.t
  @type node_ :: atom

  @me __MODULE__

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    Agent.start_link(fn -> Queue.new() end, name: @me)
  end

  @spec add_node(node_name) :: :ok
  def add_node(node) do
    Agent.update(@me, fn nodes -> Queue.insert(nodes, String.to_atom(node)) end)
  end

  def next_node() do
    Agent.get_and_update(@me, fn nodes ->
      {next_node, popped_queue} = Queue.pop(nodes)
      new_queue = Queue.insert(popped_queue,next_node)      
      {next_node,new_queue}
    end)
  end

  def all_nodes() do
    Agent.get(@me, fn nodes -> Queue.to_list(nodes) end)
  end
end