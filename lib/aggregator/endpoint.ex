defmodule Aggregator.Endpoint do
  @moduledoc """
  """

  require Logger

  use Plug.Router

  alias Aggregator.Stories
  alias Aggregator.HalHelper
  alias Aggregator.EndpointHelper

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "hello there!")
  end

  get "/top_stories" do

    stories_resp =
      EndpointHelper.paginate_stories(Stories.get_stories(), conn.params)
      |> HalHelper.format_page_json( conn)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, stories_resp)
  end

  get "/story/:id" do
     Logger.info("Requested story #{id}")
     story_id = String.to_integer(id)

     res = conn
     |> put_resp_content_type("application/json")

     case Stories.get_story(story_id) do
        {:ok, story} when story.type == "story" ->
          story_json = EndpointHelper.format_story(story, conn)
          send_resp(res, 200, story_json)
        {:ok, _story} ->
          reason = "The provided id exists, but it doesn't correspond to a story"
          error_resp = EndpointHelper.create_error_response(reason, conn)
          send_resp(res, 500, error_resp)
        {:error, reason} when is_binary(reason) ->
          error_resp = EndpointHelper.create_error_response(reason, conn)
          send_resp(res, 404, error_resp)
        {:error, %HTTPoison.Error{reason: reason} = error} ->
          inspect HTTPoison.Error.message(error)
          send_resp(res, 500, "{#{reason}}")
     end
  end

end
