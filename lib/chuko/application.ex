defmodule Chuko.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ChukoWeb.Telemetry,
      # Start the Ecto repository
      Chuko.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Chuko.PubSub},
      # Start Finch
      {Finch, name: Chuko.Finch},
      # Start the Endpoint (http/https)
      ChukoWeb.Endpoint
      # Start a worker by calling: Chuko.Worker.start_link(arg)
      # {Chuko.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chuko.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChukoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
