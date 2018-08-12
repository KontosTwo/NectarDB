defmodule NectarAPIWeb.CommunicationService do

  alias NectarAPI.Broadcast.RPC

  import GenRetry

  @retries_per_write :infinity
  @delay_per_write 100
  @retries_per_read 10
  @delay_per_read 1

  def write(node, {time, {:write, key, value}}) do
    GenRetry.retry(
      fn -> 
        RPC.call(node, NectarNode.Server,:write,[time, key,value]) 
      end,
      retries: @retries_per_write,
      delay: @delay_per_write
    )
    :ok
  end

  def write(node, {time, {:delete, key}}) do
    GenRetry.retry(
      fn -> RPC.call(node, NectarNode.Server,:delete,[time, key]) end,
      retries: @retries_per_write,
      delay: @delay_per_write
    )
    :ok
  end

  def read(node, {time,{:read, key}}) do
    task = GenRetry.Task.async(
      fn -> RPC.call(node, NectarNode.Server,:read,[time, key]) end,
      retries: @retries_per_read,
      delay: @delay_per_read
    )
    Task.await(task)
  end
end