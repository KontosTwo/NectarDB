defmodule NectarNode.OpqueueSupervisor do
  use DynamicSupervisor

  alias NectarNode.OpqueueWorker

  @me __MODULE__

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  @impl true
  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_worker() do
    {:ok, _pid} = DynamicSupervisor.start_child(@me, OpqueueWorker)
  end
end