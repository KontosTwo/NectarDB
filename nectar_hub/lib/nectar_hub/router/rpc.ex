defmodule NectarHub.Router.RPC do

  @spec rpc(atom,atom,atom,[any]) :: :ok
  def rpc(node, module, fun, args) do
    :rpc.call(node, module, fun, args)
    :ok
  end
end