defmodule NectarHub.Broadcast.Supervisor do
  use ConsumerSupervisor

  alias NectarHub.Broadcast.Worker
  alias NectarHub.Broadcast.Generator

  @me __MODULE__

  def start_link(_args) do
    ConsumerSupervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  @impl true
  def init(:no_args) do
    children = [
      worker(Worker, [], restart: :transient)
    ]

    {:ok, children, strategy: :one_for_one, subscribe_to: [{Generator, max_demand: 50}]}
  end
end