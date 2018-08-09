defmodule NectarHub.Router.Hub do
  use GenServer

  @me __MODULE__

  @type key :: any
  @type value :: any
  @type time :: integer
  

  @spec start_link(any) :: {:ok, pid}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :init, name: @me)
  end

  @spec serve_write(time,key, value) :: :ok
  def serve_write(time,key, value) do
    
  end

  @spec serve_read(time,key) :: value
  def serve_read(time,key) do

  end

  @spec serve_delete(time,key) :: :ok  
  def serve_delete(time,key) do

  end

  def init(:init) do
    {:ok, []}
  end 

  def handle_call({:write, key, value}, _from, state) do

    {:reply, :ok, state}
  end

  def handle_call({:read, key}, _from, state) do

    {:reply, :ok, state}
  end

  def handle_call({:delete, key}, _from, state) do

    {:reply, :ok, state}
  end
end