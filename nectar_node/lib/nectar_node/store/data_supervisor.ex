defmodule NectarNode.DataSupervisor do
  use Supervisor

  @me __MODULE__

  alias NectarNode.Memtable
  alias NectarNode.Oplog
  alias NectarNode.Store
  alias NectarNode.Recovery
  alias NectarNode.Changelog
  
  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    Supervisor.start_link(__MODULE__,:no_args,name: @me)
  end

  @impl true
  def init(:no_args) do
    children = [
      worker(Memtable,[[]]),
      worker(Oplog,[[]]),
      worker(Store,[[]]),
      worker(Recovery,[[]]),
      worker(Changelog,[[]]),
    ]

    Supervisor.init(children,strategy: :one_for_all)
  end
end