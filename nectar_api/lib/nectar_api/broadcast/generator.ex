defmodule NectarAPI.Broadcast.Generator do
  use GenStage

  alias NectarAPI.Util.Queue

  @me __MODULE__
  
  @type key :: any
  @type value :: any
  @type time :: integer
  @type operation :: {:write, key, value} | {:read, key} | {:delete, key}  
  @type entry :: {time, operation}

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenStage.start_link(__MODULE__, :no_args, name: @me)
  end

  @spec broadcast(node,entry) :: :ok
  def broadcast(node,entry) do
    GenStage.call(@me, {:broadcast,node,entry})
  end

  @impl true
  def init(:no_args) do
    {:producer, Queue.new}
  end

  @impl true
  def handle_call({:broadcast,node,entry},_from, messages) do
    {:reply,:ok,[{node,entry}],Queue.insert(messages,{node,entry})}
  end

  @impl true
  def handle_demand(demand, entries) do
    {demanded, remaining} = Queue.split(entries,demand)
    {:noreply,Queue.to_list(demanded), remaining}
  end
end