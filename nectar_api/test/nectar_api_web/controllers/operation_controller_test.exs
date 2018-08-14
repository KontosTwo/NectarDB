defmodule NectarAPIWeb.OperationControllerTest do
  use ExUnit.Case, async: false
  use NectarAPIWeb.ConnCase

  alias NectarAPIWeb.Endpoint
  alias NectarAPI.Time.Clock
  alias NectarAPI.Router.Nodes

  setup do
    start_supervised!(Clock)
    start_supervised!(Endpoint)
    start_supervised!(Nodes)
    :ok
  end

  describe "writing" do
    test "one write", %{conn: conn} do
      Nodes.add_node("a@com")
      body = %{
        "writes" => [
          %{
            "type" => "write",
            "key" => 1,
            "value" => 2
          }
        ]
      }
      conn = conn
      |> post("/write",body)

      body = conn
      |> response(201)
      |> Poison.decode!()

      assert body["message"] != nil
    end

    test "mulitple writes", %{conn: conn} do
      Nodes.add_node("a@com")      
      body = %{
        "writes" => [
          %{
            "type" => "write",
            "key" => 1,
            "value" => 2
          },
          %{
            "type" => "write",
            "key" => 1,
            "value" => 2
          },
          %{
            "type" => "write",
            "key" => 1,
            "value" => 2
          }
        ]
      }
      conn = conn
      |> post("/write",body)

      body = conn
      |> response(201)
      |> Poison.decode!()

      assert body["message"] != nil
    end

    test "one delete", %{conn: conn} do
      Nodes.add_node("a@com")
      
      body = %{
        "writes" => [
          %{
            "type" => "delete",
            "key" => 1,
          }
        ]
      }
      conn = conn
      |> post("/write",body)

      body = conn
      |> response(201)
      |> Poison.decode!()

      assert body["message"] != nil
    end

    test "mulitple deletes", %{conn: conn} do
      Nodes.add_node("a@com")
      
      body = %{
        "writes" => [
          %{
            "type" => "delete",
            "key" => 1,
          },
          %{
            "type" => "delete",
            "key" => 1,
          },
          %{
            "type" => "delete",
            "key" => 1,
          }
        ]
      }
      conn = conn
      |> post("/write",body)

      body = conn
      |> response(201)
      |> Poison.decode!()

      assert body["message"] != nil
    end

    test "malformed body", %{conn: conn} do
      Nodes.add_node("a@com")
      
      body = %{
        "incorrect" => [
          %{
            "type" => "write",
            "key" => 1,
            "value" => 2
          }
        ]
      }
      conn = conn
      |> post("/write",body)

      body = conn
      |> response(400)
      |> Poison.decode!()

      assert body["message"] != nil
    end

    test "no nodes for write", %{conn: conn} do
      body = %{
        "writes" => [
          %{
            "type" => "write",
            "key" => 1,
            "value" => 2
          }
        ]
      }
      conn = conn
      |> post("/write",body)

      body = conn
      |> response(503)
      |> Poison.decode!()

      assert body["message"] != nil
    end

    test "no nodes for delete", %{conn: conn} do
      body = %{
        "writes" => [
          %{
            "type" => "delete",
            "key" => 1,
          }
        ]
      }
      conn = conn
      |> post("/write",body)

      body = conn
      |> response(503)
      |> Poison.decode!()

      assert body["message"] != nil
    end
  end

  describe "reading" do
    test "reads one value"
  end
end