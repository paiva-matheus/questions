defmodule Questions.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      QuestionsWeb.Telemetry,
      Questions.Repo,
      {DNSCluster, query: Application.get_env(:questions, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Questions.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Questions.Finch},
      # Start a worker by calling: Questions.Worker.start_link(arg)
      # {Questions.Worker, arg},
      # Start to serve requests, typically the last entry
      QuestionsWeb.Endpoint,
      {Oban, Application.fetch_env!(:questions, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Questions.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QuestionsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
