defmodule AlphaVantageApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {ConCache, [
        name: :default,
        ttl_check_interval: :timer.seconds(1),
        global_ttl: :timer.seconds(60)
      ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AlphaVantageApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
