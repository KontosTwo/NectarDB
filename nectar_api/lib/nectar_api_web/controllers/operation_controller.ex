defmodule NectarAPIWeb.OperationController do
  use NectarAPIWeb, :controller

  alias NectarAPIWeb.CommunicationService
  alias NectarAPIWeb.OperationService
  alias NectarAPI.Util.Queue

  alias NectarAPI.Exceptions.ReadNodesUnresponsive
  alias NectarAPI.Exceptions.NoNodes
  
  
  def write(conn, %{"writes" => writes}) when is_list(writes) do
    try do
      writes
      |> OperationService.parse_write()
      |> Queue.to_list()
      |> Enum.each(fn write->
        CommunicationService.write(write)
      end)
    rescue 
      NoNodes ->        
        conn
        |> put_status(503)
        |> json(%{message: "No nodes are linked to the api. Please start a nectar_node"})
      _ ->         
        conn
        |> put_status(:bad_request)
        |> json(%{message: "Body is malformed. Please follow the format"})
    else
      _ -> conn
        |> put_status(:created)
        |> json(%{message: "Successful write!"})
    end    
  end

  def write(conn, _malformed) do
    conn
    |> put_status(:bad_request)
    |> json(%{message: "Body is malformed. Please follow the format"})
  end

  def read(conn, %{"reads" => reads}) when is_list(reads) do
    conn
    |> json(reads)
  end

  def read(conn, _malformed) do
    conn
    |> put_status(:bad_request)
    |> json(%{message: "Body is malformed. Please follow the format"})
  end
end
