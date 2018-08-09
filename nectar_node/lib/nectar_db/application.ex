defmodule NectarDb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec

  alias NectarDb.Communicator
  alias NectarDb.Server
  alias NectarDb.DataSupervisor

  def start(_type, _args) do
    #if (unquote(Mix.env()) != :test), do: Node.start(:b@localhost, :shortnames)
    # List all child processes to be supervised




    
    # DO NOT USE Mix.env in RELEASE




    children = if (unquote(Mix.env()) != :test), do: [
      # Starts a worker by calling: NectarDb.Worker.start_link(arg)
      # {NectarDb.Worker, arg},
      worker(Communicator, [[]]),
      supervisor(DataSupervisor,[[]]),
      worker(Server, [[]]),    
      supervisor(Task.Supervisor,[[name: NectarDb.TaskSupervisor]])
    ], else: []

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NectarDb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end