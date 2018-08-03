defmodule NectarDb.Server do
  alias NectarDb.Store
  alias NectarDb.Oplog
  alias NectarDb.Memtable
  alias NectarDb.TaskSupervisor
  alias NectarDb.Clock
  alias NectarDb.Changelog

  use GenServer

  @me __MODULE__

  @type time :: integer
  @type key :: any
  @type value :: any
  @type kv :: %{key => value}
  @type operation :: {:write, key, value} | {:delete, key} | {:rollback, time}
  @type oplog_entry :: {time, operation}
  @type changelog_entry :: {:write,key,value} | {:delete,key}

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  @impl true
  def init(:no_args) do
    {:ok, nil}
  end


  @doc """

  """
  @spec write(key, value) :: :ok
  def write(key, value) do
    GenServer.call(@me, {:write,key,value})
  end

  @doc """

  """
  @spec delete(key) :: :ok
  def delete(key) do
    GenServer.call(@me, {:delete,key})
  end

  @doc """

  """
  @spec read(key) :: value
  def read(key) do
    GenServer.call(@me, {:read,key})    
  end


  @doc """

  """
  @spec rollback(time) :: :ok
  def rollback(time) when is_integer(time) do
    GenServer.call(@me, {:rollback,time})        
  end

  @doc """

  """
  @spec get_history() :: [oplog_entry]
  def get_history() do
    GenServer.call(@me,:get_history)
  end

  @spec receive_oplog_entry(oplog_entry) :: :ok
  def receive_oplog_entry(oplog_entry) do
    GenServer.call(@me, {:receive_oplog_entry,oplog_entry})
  end

  @doc """

  """
  @spec health_check() :: boolean
  def health_check() do
    GenServer.call(@me,:health_check)
  end

  @impl true
  def handle_call({:write, key, value},_from, state) do
    Oplog.add_log({Clock.get_time(),{:write, key, value}})    
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:delete, key},_from, state) do
    Oplog.add_log({Clock.get_time(),{:delete, key}})    
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:read, key},_from, state) do
    store_before = Store.get_all()

    sorted_oplog =
      Oplog.get_logs()
      |> List.keysort(0)

    changelogs = Changelog.get_changelogs()
    repaired_oplog = 

    memtable_task = Task.Supervisor.async(TaskSupervisor,fn ->
      Enum.each(sorted_oplog, fn {time, operation} ->
        Memtable.add_log(time, operation)
      end)
    end)

    rollbacked_oplog = Enum.reduce(sorted_oplog, [], fn entry, acc->
      case entry do
        {_time,{:rollback,to}} -> rollback_oplog(acc,to)
        other_entry -> [other_entry | acc]
      end
    end)
    |> Enum.reverse

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

    Task.await(write_task)

    store_after = Store.get_all()
    changelog_task = Task.Supervisor.async(TaskSupervisor,fn ->
      diff = get_diff(store_before,store_after)
      Changelog.add_changelog(diff)
    end)

    value = Store.get_v(key)

    Task.await(memtable_task)    
    Task.await(changelog_task)
    
    {:reply, value, state}
  end

  @impl true
  def handle_call({:rollback, to},_from, state) do
    Oplog.add_log({Clock.get_time(),{:rollback,to}})    
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:get_history,_from, state) do
    history = Oplog.get_logs() ++ Memtable.get_logs()
      |> List.keysort(0)
    {:reply, history,state}
  end

  @impl true
  def handle_call(:health_check,_from, state) do
    {:reply, Node.alive?(),state}
  end

  @impl true
  def handle_call({:receive_oplog_entry,oplog_entry},_from, state) do
    Oplog.add_log(oplog_entry)
    {:reply, :ok,state}
  end

  @spec rollback_oplog([oplog_entry],integer) :: [oplog_entry]
  defp rollback_oplog(oplog_entries,to) when is_list(oplog_entries) and is_integer(to) do
    Enum.reduce oplog_entries, [], fn {time,op}, acc ->
      if time > to, do: acc, else: [{time,op} | acc]
    end
  end

  @spec get_diff(%{},%{}) :: {time,[changelog_entry]}
  defp get_diff(before, after_) do
    time = Clock.get_time()
    changelog = []
    b_keys = Map.keys(before)
    a_keys = Map.keys(after_)
    removed =  b_keys -- a_keys
    added = a_keys -- b_keys
    stayed = Enum.reduce a_keys ,[], fn element,acc ->
      if element in b_keys, do: [element | acc], else: acc
    end

    changelog = Enum.reduce removed, changelog,fn (key,changelog) ->
      [{:write,key,before[key]} | changelog]
    end

    changelog = Enum.reduce added, changelog,fn (key,changelog) ->
      [{:delete,key} | changelog]
    end

    changelog = Enum.reduce stayed, changelog,fn (key,changelog) ->
      cond do
        before[key] == after_[key] -> changelog
        before[key] != after_[key] -> [{:write,key,before[key]} | changelog]
      end
    end

    {time, changelog}
  end
end
