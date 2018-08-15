defmodule NectarAPIWeb.Router do
  use NectarAPIWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NectarAPIWeb do
    pipe_through :api # Use the default browser stack

    post "/write", OperationController, :write
    post "/read", OperationController, :read
  end

  # Other scopes may use custom stacks.
  # scope "/api", NectarAPIWeb do
  #   pipe_through :api
  # end
end
