defmodule NectarAPIWeb.OperationController do
  use NectarAPIWeb, :controller

  alias NectarAPIWeb.CommunicationService
  alias NectarAPIWeb.OperationService
  
  def write(conn, %{"writes" => writes})do
    writes
    |> OperationService.parse_write()
    |> Enum.each(fn ->
      CommunicationService.
    end)
    conn
    |> json(writes)
  end

  def read(conn, %{"reads" => reads}) do
    conn
    |> json(reads)
  end
end
