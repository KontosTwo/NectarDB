defmodule NectarNode.Recovery do
  use GenServer

  alias NectarNode.Oplog

  @me __MODULE__

  @spec start_link(node) :: {:ok, pid}
  def start_link(api_node) do
    GenServer.start_link(__MODULE__, api_node, name: @me)
  end

  @impl true
  def init(api_node) do
    Process.send_after(self(), {:recovery,api_node}, 0)
    {:ok, nil}
  end

  @impl true
  def handle_info({:recovery,api_node}, state) do
    history = :rpc.call(api_node, NectarAPI.Broadcast.Hub,:request_history,[Node.self()])
    Enum.each history, fn history_log ->
      Oplog.add_log(history_log)
    end
    {:noreply,state}
  end
end
