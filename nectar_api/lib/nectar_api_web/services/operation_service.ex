defmodule NectarAPIWeb.OperationService do

  alias NectarAPI.Time.Clock
  alias NectarAPI.Util.Queue

  defp write(%{"type" => "write","key" => key, "value" => value}) do
    {:write, key, value}
  end

  defp write(%{"type" => "delete","key" => key}) do
    {:delete, key}
  end

  defp read(%{"key" => key}) do
    {:read, key}
  end

  def parse_write(writes) do
    queue = Queue.new()
    Enum.reduce writes, queue, fn write,acc ->
      Queue.insert acc,{Clock.get_and_tick(),write(write)}
    end    
  end

  def parse_read(reads) do
    queue = Queue.new()
    Enum.reduce reads, queue, fn read,acc ->
      Queue.insert acc,{Clock.get_and_tick(),read(read)}
    end 
  end
end
