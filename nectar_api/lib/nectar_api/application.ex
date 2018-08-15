defmodule NectarAPI.Application do
  use Application

  alias NectarAPI.Router.Nodes
  alias NectarAPI.Time.Clock
  alias GenRetry
  

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec
    Node.start(:nectar_api)
    Node.set_cookie(:NectarDB)
    
    IO.inspect("NectarAPI started at node " <> Atom.to_string(Node.self()))
    children = if (unquote(Mix.env()) != :test), do: [
      # Starts a worker by calling: NectarNode.Worker.start_link(arg)
      # {NectarNode.Worker, arg},
      supervisor(NectarAPIWeb.Endpoint, []),
      worker(Nodes,[[]]),
      worker(Clock,[[]])
    ], else: []
    # Define workers and child supervisors to be supervised
    

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NectarAPI.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NectarAPIWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
