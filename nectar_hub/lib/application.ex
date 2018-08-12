defmodule NectarHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec

  alias NectarHub.Router.Hub
  alias NectarHub.Router.Nodes
  alias NectarHub.Broadcast.Generator
  alias NectarHub.Broadcast
  
  def start(_type, _args) do
    #if (unquote(Mix.env()) != :test), do: Node.start(:b@localhost, :shortnames)
    # List all child processes to be supervised




    
    # DO NOT USE Mix.env in RELEASE




    children = if (unquote(Mix.env()) != :test), do: [
      worker(Hub,[nil]),
      worker(Nodes,[nil]),
      worker(Generator,[nil]),
      supervisor(Broadcast.Supervisor,[nil])
    ], else: []

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NectarNode.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
