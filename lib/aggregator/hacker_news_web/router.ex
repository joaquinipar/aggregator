defmodule Aggregator.HackerNewsWeb.Router do
  @moduledoc """
  """

  require Logger

  use Plug.Router

  alias Aggregator.Stories
  alias Aggregator.HackerNewsWeb.Controller

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "hello there!")
  end

  get "/top_stories" do

    {code, stories_resp} =
      Stories.get_stories()
      |> Controller.get_top_stories_response(conn)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, stories_resp)
  end

  get "/story/:id" do
    Logger.info("Requested story #{id}")
    story_id = String.to_integer(id)

    res = conn
    |> put_resp_content_type("application/json")

    {code, content} =
      story_id
      |> Stories.get_story
      |> Controller.get_story_response(conn)

      send_resp(res, code, content)
  end

end
