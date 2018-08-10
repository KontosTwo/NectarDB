defmodule NectarAPIWeb.OperationController do
  use NectarAPIWeb, :controller

  def write(conn, %{"writes" => writes})do
    conn
    |> json(writes)
  end

  def read(conn, %{"reads" => reads}) do
    conn
    |> json(reads)
  end
end
