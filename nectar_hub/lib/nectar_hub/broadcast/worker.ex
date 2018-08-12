defmodule NectarHub.Broadcast.Worker do

  alias NectarHub.Broadcast.Generator
  alias NectarHub.Broadcast.RPC
  

  @spec start_link({node,Generator.entry}) :: {:ok, pid}
  def start_link({node,entry}) do
    Task.start_link(fn ->
      RPC.call(node, NectarNode.Server,:receive_oplog_entry,[entry])
    end)
  end
end