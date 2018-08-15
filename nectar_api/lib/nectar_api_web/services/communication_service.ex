defmodule NectarAPIWeb.CommunicationService do

  alias NectarAPI.Broadcast.RPC
  alias NectarAPI.Util.Queue
  alias NectarAPI.Router.Nodes
  alias NectarAPI.Exceptions.NoNodes
  alias NectarAPI.Exceptions.NodesUnresponsive
  alias GenRetry

  use Retry

  @retries_per_write :infinity
  @delay_per_write 100
  @retries_per_read 10
  @delay_per_read 100

  def write({time, {:write, key, value}}) do
    num_of_nodes = Nodes.all_nodes()
    |> queue_to_list()
    |> length()

    if(num_of_nodes == 0) do      
      raise NoNodes
    end

    Enum.each(queue_to_list(Nodes.all_nodes()), fn node ->
      GenRetry.retry(
        fn -> 
          RPC.call(node, NectarNode.Server,:write,[time, key,value]) 
        end,
        retries: @retries_per_write,
        delay: @delay_per_write,
        exp_base: 1
      )
    end)
    :ok
  end

  def write({time, {:delete, key}}) do
    num_of_nodes = Nodes.all_nodes()
    |> queue_to_list()
    |> length()

    if(num_of_nodes == 0) do      
      raise NoNodes
    end
    
    Enum.each(queue_to_list(Nodes.all_nodes()), fn node ->
      GenRetry.retry(
        fn -> 
          RPC.call(node, NectarNode.Server,:delete,[time, key]) 
        end,
        retries: @retries_per_write,
        delay: @delay_per_write,
        exp_base: 1
      )
    end)
    :ok
  end

  defp queue_to_list(queue) when is_list(queue) do
    queue
  end

  defp queue_to_list(queue), do: Queue.to_list(queue)

  def read({time,{:read, key}}) do
    num_of_nodes = Nodes.all_nodes()
    |> queue_to_list()
    |> length()

    if(num_of_nodes == 0) do      
      raise NoNodes
    end

    # task = GenRetry.Task.async(
    #   fn -> 
    #     value = RPC.call(Nodes.next_node(), NectarNode.Server,:read,[time, key]) 
    #     case value do
    #       {:badrpc, _reason} -> raise NodesUnresponsive
    #       value -> value
    #     end
    #   end,
    #   retries: @retries_per_read * num_of_nodes,
    #   delay: @delay_per_read / num_of_nodes,
    #   exp_base: 1
    # )
    # Task.await(task)

    rpc_result = retry with: lin_backoff(10, 1) |> cap(1_000) |> Stream.take(10) do
      result = RPC.call(Nodes.next_node(), NectarNode.Server,:read,[time, key])
      case result do
        {:badrpc, _reason} -> :error
        valid_result -> valid_result
      end
    after
      result -> result
    else
      error -> error
    end

    if(rpc_result == :error) do
      raise NodesUnresponsive
    else
      rpc_result
    end
  end
end