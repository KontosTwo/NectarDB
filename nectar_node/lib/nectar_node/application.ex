defmodule NectarNode.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec

  alias NectarNode.Server
  alias NectarNode.DataSupervisor

  def start(_type, _args) do
    # List all child processes to be supervised
    
    if (unquote(Mix.env()) != :test) do
      args = Enum.map(:init.get_plain_arguments(), &List.to_string/1)
      third = Enum.at(args,3)
      split = String.split(third)
      node = Enum.at(split,1)
      |> String.to_atom()
      api_node = Enum.at(split,2)
      |> String.to_atom()
  
      Node.stop()
      Node.start(node, :longnames)
      Node.set_cookie(:NectarDB)
      
  
      successful = Node.connect(api_node)
  
      if(successful) do
        :rpc.call(api_node, NectarAPI.Router.Nodes, :add_node, [Node.self()])
        children = [
          supervisor(DataSupervisor,[[]]),
          worker(Server, [[]]),    
          supervisor(Task.Supervisor,[[name: NectarNode.TaskSupervisor]])
        ]
    
        opts = [strategy: :one_for_one, name: NectarNode.Supervisor]
        Supervisor.start_link(children, opts)
      else
        IO.inspect "Could not connect to node " <> Atom.to_string(api_node)
        exit(:shutdown) 
      end
    else

      children = [
        
      ]
  
      opts = [strategy: :one_for_one, name: NectarNode.Supervisor]
      Supervisor.start_link(children, opts)
    end
  end
end
