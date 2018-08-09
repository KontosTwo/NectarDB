defmodule NectarNode.Changelog do
  @moduledoc """
    Every read operation from Server stores
    a changelog that details how to reverse the
    read-repair
  """

  use GenServer

  @me __MODULE__

  @type time :: integer
  @type key :: any
  @type value :: any
  @type kv :: %{key => value}
  @type changelog_entry :: {:write,key,value} | {:delete,key}
  
  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  @spec add_changelog({time,[changelog_entry]}) :: :ok
  def add_changelog(entry) do
    GenServer.call(@me, {:add_changelog,entry})
  end

  @spec rollback_changelog() :: :ok
  def rollback_changelog() do
    GenServer.call(@me, :rollback_changelog)
  end

  @spec get_changelogs() :: [{time, [changelog_entry]}]
  def get_changelogs() do
    GenServer.call(@me, :get_changelogs)
  end

  @impl true
  def handle_call({:add_changelog,entry},_from,entries) do
    {:reply,:ok,[entry | entries]}
  end

  @impl true
  def handle_call(:get_changelogs,_from,entries) do
    {:reply,entries,entries}
  end

  @impl true
  def handle_call(:rollback_changelog,_from,entries) do
    case entries do
      [_h | t] -> {:reply,:ok,t}
      [] -> {:reply,:ok,entries}
    end
  end

  @impl true
  def init(:no_args) do
    {:ok,[{0,[]}]}
  end
end