defmodule NectarDb.Changelog do
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

  @spec get_changelogs() :: [{time, changelog_entry}]
  def get_changelogs() do
    GenServer.call(@me, :get_changelogs)
  end

  @impl true
  def handle_call({:add_changelog,entry},_from,entries) do
    {:reply,:ok,[entry | entries]}
  end

  @impl true
  def handle_call(:get_changelogs,_from,entries) do
    sorted_changelogs = Enum.sort_by(entries,fn {time,_entry} ->
      time
    end)
    {:reply,sorted_changelogs,entries}
  end

  @impl true
  def init(:no_args) do
    {:ok,[]}
  end
end