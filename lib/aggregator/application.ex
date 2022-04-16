defmodule Aggregator.Application do
  @moduledoc """
    Main supervisor of the Application
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # {Aggregator.Worker, arg}
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Aggregator.Endpoint,
        options: [port: 4000]
      ),
      {Task.Supervisor, name: Task.FetchSupervisor},
      Aggregator.Stories
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
