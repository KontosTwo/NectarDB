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
    parsed_reads = try do
      reads
      |> OperationService.parse_read()
      |> Queue.to_list()
    rescue 
      _ ->         
        :malformed
    end

    case parsed_reads do
      :malformed -> 
        conn
        |> put_status(:bad_request)
        |> json(%{message: "Body is malformed. Please follow the format"})
      _ -> 
        read_results = parsed_reads
        |> Enum.map(fn {time,{:read, key}}->
          try do
            {key,CommunicationService.read({time,{:read, key}})}
          rescue
            NoNodes -> {key,:no_nodes}
            ReadNodesUnresponsive -> {key,:nodes_unresponsive}
            _ -> {key,:failure}
          end
        end)
    
        successes = Enum.filter(read_results, fn {_key,result} -> !read_failure?(result) end)
        |> Enum.map(fn {key, result} -> %{"key" => key, "result" => result}end)
        failures = Enum.filter(read_results, fn {_key,result} -> read_failure?(result) end)
        |> Enum.map(fn {key, result} -> %{"key" => key, "result" => result}end)    
        no_nodes = Enum.find(read_results, nil, fn {_key, result} -> result == :no_nodes end)
        if(no_nodes != nil) do
          conn
          |> put_status(503)
          |> json(%{message: "No nodes are linked to the api. Please start a nectar_node"})
        else
          body = %{
            "successes" => successes,
            "failures" => failures
          }
          conn
          |> put_status(200)
          |> json(body)
        end
    end
  end

  def read(conn, _malformed) do
    conn
    |> put_status(:bad_request)
    |> json(%{message: "Body is malformed. Please follow the format"})
  end

  defp read_failure?(:no_nodes), do: true
  defp read_failure?(:nodes_unresponsive), do: true
  defp read_failure?(:failure), do: true
  defp read_failure?(_), do: false
end
