defmodule NectarAPIWeb.OperationController do
  use NectarAPIWeb, :controller

  def write(conn, %{"operations" => operations})do
    conn
    |> json(operations)
  end

  def read(conn, %{"reads" => reads}) do
    conn
    |> json(reads)
  end
end
