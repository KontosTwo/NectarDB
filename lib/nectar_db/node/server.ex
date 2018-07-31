defmodule NectarDb.Server do
  alias NectarDb.Store
  alias NectarDb.Oplog
  alias NectarDb.Memtable
  alias NectarDb.TaskSupervisor
  alias NectarDb.Clock

  @type time :: integer
  @type key :: any
  @type value :: any
  @type kv :: %{key => value}
  @type operation :: {:write, key, value} | {:delete, key} | {:rollback, time}
  @type oplog_entry :: {time, operation}

  @doc """

  """
  @spec write(key, value) :: :ok
  def write(key, value) do
    task = Task.Supervisor.async(TaskSupervisor,fn ->
      Clock.get_time()
      |> Oplog.add_log({:write, key, value})
    end)
    Task.await(task)
    :ok
  end

  @doc """

  """
  @spec delete(key) :: :ok
  def delete(key) do
    task = Task.Supervisor.async(TaskSupervisor,fn ->
      Clock.get_time()
      |> Oplog.add_log({:delete, key})
    end)

    Task.await(task)

    :ok
  end

  @doc """

  """
  @spec read(key) :: value
  def read(key) do
    sorted_oplog =
      Oplog.get_logs()
      |> List.keysort(0)

    rollbacked_oplog =  Enum.reduce( sorted_oplog, [], fn entry, acc->
      case entry do
        {_time,{:rollback,to}} -> rollback_oplog(acc,to)
        other_entry -> [other_entry | acc]
      end
    end)
    |> Enum.reverse

    memtable_task = Task.Supervisor.async(TaskSupervisor,fn ->
      Enum.each(rollbacked_oplog, fn {time, operation} ->
        Memtable.add_log(time, operation)
      end)
    end)

    write_task = Task.Supervisor.async(TaskSupervisor,fn ->
      Enum.map rollbacked_oplog, fn {_time, operation} ->
        case operation do
          {:write, key, value} ->
            Store.store_kv(key, value)

          {:delete, key} ->
            Store.delete_k(key)

          _ ->
            nil
        end
      end
    end)

    Oplog.flush()

    Task.await(memtable_task)
    Task.await(write_task)


    Store.get_v(key)
  end

  @doc """
    Assumes that oplog_entries is sorted
  """
  @spec rollback_oplog([oplog_entry],integer) :: [oplog_entry]
  defp rollback_oplog(oplog_entries,to) do
    require IEx; IEx.pry
    Enum.reduce oplog_entries, [], fn {time,op}, acc ->
      if time > to, do: acc, else: [{time,op} | acc]
    end
  end

  @doc """

  """
  @spec rollback(time) :: :ok
  def rollback(time) do
    task = Task.Supervisor.async(TaskSupervisor,fn ->
      Clock.get_time()
      |> Oplog.add_log({:rollback, time})
    end)

    Task.await(task)

    :ok
  end

  @doc """

  """
  @spec get_history() :: [oplog_entry]
  def get_history() do
    task = Task.Supervisor.async(TaskSupervisor,fn ->
      Oplog.get_logs() ++ Memtable.get_logs()
      |> List.keysort(0)
    end)
    Task.await task
  end

  @doc """

  """
  def health_check() do
    Node.alive?
  end
end
