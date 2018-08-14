defmodule NectarAPIWeb.OperationControllerTest do
  use ExUnit.Case, async: false
  use NectarAPIWeb.ConnCase

  alias NectarAPIWeb.Endpoint
  alias NectarAPI.Time.Clock
  alias NectarAPI.Router.Nodes
  alias NectarAPI.Broadcast.RPC
  
  import Mock

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

    test "malformed inner", %{conn: conn} do
      Nodes.add_node("a@com")
      
      body = %{
        "writes" => [
          %{
            "malformed" => "write",
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
    test "reads one value", %{conn: conn} do
      with_mock(
        RPC, call: fn _node, _module, _fun, _args -> 2 end
      ) do
        Nodes.add_node("a@com")
        
        body = %{
          "reads" => [
            %{
              "type" => "read",
              "key" => 1,
            }
          ]
        }
        conn = conn
        |> post("/read",body)

        body = conn
        |> response(200)
        |> Poison.decode!()

        assert body == %{
          "successes" => [
            %{
              "key" => 1,
              "result" => 2
            }
          ],
          "failures" => [
            
          ]
        }
      end
    end

    test "reads multiple value", %{conn: conn} do
      with_mock(
        RPC, call: fn _node, _module, _fun, _args -> 2 end
      ) do
        Nodes.add_node("a@com")
        
        body = %{
          "reads" => [
            %{
              "type" => "read",
              "key" => 1,
            },
            %{
              "type" => "read",
              "key" => 2,
            },
            %{
              "type" => "read",
              "key" => 3,
            }
          ]
        }
        conn = conn
        |> post("/read",body)

        body = conn
        |> response(200)
        |> Poison.decode!()

        assert body == %{
          "successes" => [
            %{
              "key" => 1,
              "result" => 2
            },
            %{
              "key" => 2,
              "result" => 2
            },
            %{
              "key" => 3,
              "result" => 2
            }
          ],
          "failures" => [
            
          ]
        }
      end
    end

    test "some reads fail due to unresponsive node", %{conn: conn} do
      with_mock(
        RPC, call: fn _node, _module, _fun, [_time, key] -> 
          if(key == 1) do
            :nodes_unresponsive
          else
            2
          end
        end
      ) do
        Nodes.add_node("a@com")
        
        body = %{
          "reads" => [
            %{
              "type" => "read",
              "key" => 1,
            },
            %{
              "type" => "read",
              "key" => 2,
            }
          ]
        }
        conn = conn
        |> post("/read",body)

        body = conn
        |> response(200)
        |> Poison.decode!()

        assert body == %{
          "successes" => [
            %{
              "key" => 2,
              "result" => 2
            }
          ],
          "failures" => [
            %{
              "key" => 1,
              "result" => "nodes_unresponsive"
            }
          ]
        }
      end
    end

    test "all reads fail due to unresponsive node", %{conn: conn} do
      with_mock(
        RPC, call: fn _node, _module, _fun, [_time, _key] -> 
          :nodes_unresponsive
        end
      ) do
        Nodes.add_node("a@com")
        
        body = %{
          "reads" => [
            %{
              "type" => "read",
              "key" => 1,
            },
            %{
              "type" => "read",
              "key" => 2,
            }
          ]
        }
        conn = conn
        |> post("/read",body)

        body = conn
        |> response(200)
        |> Poison.decode!()

        assert body == %{
          "successes" => [
            
          ],
          "failures" => [
            %{
              "key" => 1,
              "result" => "nodes_unresponsive"
            },
            %{
              "key" => 2,
              "result" => "nodes_unresponsive"
            }
          ]
        }
      end
    end

    test "read fails due to malformed body", %{conn: conn} do
      with_mock(
        RPC, call: fn _node, _module, _fun, [_time, _key] -> 
          :nodes_unresponsive
        end
      ) do
        Nodes.add_node("a@com")
        
        body = %{
          "malformed" => [
            %{
              "type" => "read",
              "key" => 1,
            }
          ]
        }
        conn = conn
        |> post("/read",body)

        body = conn
        |> response(400)
        |> Poison.decode!()

        assert body["message"] != nil
      end
    end

    test "read fails due to malformed inner body", %{conn: conn} do
      with_mock(
        RPC, call: fn _node, _module, _fun, [_time, _key] -> 
          :nodes_unresponsive
        end
      ) do
        Nodes.add_node("a@com")
        
        body = %{
          "reads" => [
            %{
              "malformed" => "read",
              "key" => 1,
            }
          ]
        }
        conn = conn
        |> post("/read",body)

        body = conn
        |> response(400)
        |> Poison.decode!()

        assert body["message"] != nil
      end
    end

    test "returns 503 for no nodes", %{conn: conn} do
      with_mock(
        RPC, call: fn _node, _module, _fun, _args -> 2 end
      ) do
        
        body = %{
          "reads" => [
            %{
              "type" => "read",
              "key" => 1,
            }
          ]
        }
        conn = conn
        |> post("/read",body)

        body = conn
        |> response(503)
        |> Poison.decode!()

        assert body["message"] != nil        
      end
    end
  end
end