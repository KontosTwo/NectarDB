defmodule NectarAPI.Broadcast.Hub do
  use GenServer
  use Retry
  
  alias NectarAPI.Router.Nodes
  alias NectarAPI.Broadcast.RPC

  @me __MODULE__

  @type key :: any
  @type value :: any
  @type time :: integer
  @type log :: {:write, key, value} | {:delete, key} | {:read, key}
  @type entry :: {time, log}

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  @spec request_history(node) :: [entry]
  def request_history(caller) do
    GenServer.call(@me, {:request_history, caller})
  end


  @impl true
  def handle_call({:request_history, caller}, _from, state) do
    nodes = Nodes.all_nodes()
    num_nodes = length(nodes)
    rpc_result = retry with: lin_backoff(10, 1) |> cap(1_000) |> Stream.take(num_nodes) do
      node = Nodes.next_node()

      result = if(caller != node) do
        RPC.call(node, NectarNode.Server,:get_history,[])        
      else
        :same_node
      end
      
      case result do
        :same_node -> :error
        {:badrpc, _reason} -> :error
        valid_result -> valid_result
      end
    after
      result -> result
    else
      error -> error
    end

    history = case rpc_result do
      :error -> []
      valid_result -> valid_result
    end
    {:reply, history, state}
  end

  @impl true
  def init(:no_args) do
    {:ok, nil}
  end
end