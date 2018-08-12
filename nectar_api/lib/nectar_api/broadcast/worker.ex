defmodule NectarAPI.Broadcast.Worker do

  alias NectarAPI.Broadcast.Generator
  alias NectarAPI.Broadcast.RPC
  

  @spec start_link({node,Generator.entry}) :: {:ok, pid}
  def start_link({node,entry}) do
    Task.start_link(fn ->
      RPC.call(node, NectarNode.Server,:receive_oplog_entry,[entry])
    end)
  end
end