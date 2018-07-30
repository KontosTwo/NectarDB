defmodule NectarDb.Server do

  alias NectarDb.Store
  alias NectarDb.Oplog
  alias NectarDb.Memtable

  @type key :: any
  @type value :: any
  @type kv :: %{key => value}
  @type operation :: {:write, key, value} | {:delete, key}
  @type oplog_entry :: {integer, operation}
  
  @doc """
    
  """
  @spec write(key,value) :: :ok
  def write(key, value) do
    Task.async(fn ->
      :os.system_time(:seconds)
      |> Oplog.add_log({:write, key, value})
    end)
    :ok
  end


  @doc """

  """
  @spec read(key) :: value
  def read(key) do
    sorted_oplog = Oplog.get_logs()
    |> List.keysort(0)
    Enum.each sorted_oplog, fn {time,operation} ->
      case operation do
        {:write, key, value} ->          
          Store.store_kv(key,value)
        _ ->
          nil
      end
      Task.async fn ->
        Memtable.add_log(time, operation)
      end
    end
    
    Oplog.flush()
    Store.get_v(key)
  end
end