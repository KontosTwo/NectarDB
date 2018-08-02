defmodule NectarDb.Changelog do
  use GenServer

  @me __MODULE__

  @type time :: integer
  @type key :: any
  @type value :: any
  @type kv :: %{key => value}
  @type changelog_entry :: {:write,key,value} | {:delete,key}
  

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :no_args, name: @me)
  end

  @spec add_changelog_entry({time,changelog_entry}) :: :ok
  def add_changelog_entry(entry) do
    GenServer.
  end

  def init(:no_args) do
    {:ok,[]}
  end
end