defmodule Aggregator.Endpoint do
  @moduledoc """
  """

  use Plug.Router

  alias Aggregator.Stories

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "hello there!")
  end

  get "/top_stories" do
    stories = Poison.encode!(Stories.get_stories())
    send_resp(conn, 200, stories)
  end
end
