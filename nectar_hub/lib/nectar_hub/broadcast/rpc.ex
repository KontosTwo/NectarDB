defmodule NectarHub.Broadcast.RPC do

  @spec call(atom,atom,atom,[any]) :: :ok
  def call(node, module, fun, args) do
    :rpc.call(node, module, fun, args)
    :ok
  end
end