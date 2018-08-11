defmodule NectarAPIWeb.OperationControllerTest do
  use ExUnit.Case, async: false

  alias NectarAPIWeb.Endpoint

  setup do
    start_supervised!(Clock)
    start_supervised!(Endpoint)
    :ok
  end
end