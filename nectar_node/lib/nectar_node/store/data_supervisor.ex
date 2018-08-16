defmodule NectarNode.DataSupervisor do
  use Supervisor

  @me __MODULE__

  alias NectarNode.Memtable
  alias NectarNode.Oplog
  alias NectarNode.Store
  alias NectarNode.Recovery
  alias NectarNode.Changelog
  
  @spec start_link(node) :: {:ok, pid}
  def start_link(api_node) do
    Supervisor.start_link(__MODULE__,api_node,name: @me)
  end

  @impl true
  def init(api_node) do
    children = [
      worker(Memtable,[[]]),
      worker(Oplog,[[]]),
      worker(Store,[[]]),
      worker(Recovery,[api_node]),
      worker(Changelog,[[]]),
    ]

    Supervisor.init(children,strategy: :one_for_all)
  end
end