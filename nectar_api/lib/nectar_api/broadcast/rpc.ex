defmodule NectarAPI.Broadcast.RPC do

  @spec call(atom,atom,atom,[any]) :: any | {:badrpc,atom}
  def call(node, module, fun, args) do
    :rpc.call(node, module, fun, args)
  end
end