defmodule Codebeam2025.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Codebeam2025Web.Telemetry,
      Codebeam2025.Repo,
      {DNSCluster, query: Application.get_env(:codebeam_2025, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Codebeam2025.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Codebeam2025.Finch},
      # Start a worker by calling: Codebeam2025.Worker.start_link(arg)
      # {Codebeam2025.Worker, arg},
      # Start to serve requests, typically the last entry
      Codebeam2025Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Codebeam2025.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Codebeam2025Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
