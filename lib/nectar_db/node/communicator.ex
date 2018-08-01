defmodule NectarDb.Communicator do
  use GenServer

  @me __MODULE__

  @type db_node :: String.t
  @type key :: any
  @type value :: any
  @type time :: integer
  @type operation :: {:write, key, value} | {:delete, key} | {:read, key} | {:rollback, time}
  
  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :no_args,name: @me)
  end

  @spec add_node(db_node) :: :ok
  def add_node(node) do
    GenServer.cast(@me, {:add_node, node})
  end

  @spec remove_node(db_node) :: :ok
  def remove_node(node) do
    GenServer.cast(@me, {:remove_node,node})
  end

  @spec communicate_op(operation) :: :ok
  def communicate_op(operation) do
    GenServer.cast(@me,{:communicate_op,operation})
  end

  

  @impl true
  def init(:no_args) do
    {:ok,[]}
  end

  @impl true
  def handle_cast({:add_node, node},nodes) do
    {:noreply, [node | nodes]}
  end

  @impl true
  def handle_cast({:remove_node,node},nodes) do
    {:noreply,List.delete(nodes,node)}
  end

  @impl true
  def handle_cast({:communicate_op,operation},nodes) do
    :rpc.
    {:noreply,nodes}
  end
end
