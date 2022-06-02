defmodule Aggregator.HackerNewsWeb.Controller do

  alias Aggregator.HackerNewsWeb.ControllerHelper
  alias Aggregator.HackerNewsWeb.HalHelper

  def get_top_stories_response([], %Plug.Conn{} = conn) do
    response = ControllerHelper.create_error_response("There was a problem fetching the stories." , conn)
    {500, response}
  end

  def get_top_stories_response(stories, %Plug.Conn{} = conn) when is_list(stories) do
    stories_json =
      stories
      |> ControllerHelper.paginate_stories(conn.params)
      |> HalHelper.format_page_json( conn)
    {200, stories_json}
  end

  def get_story_response({:ok, story}, %Plug.Conn{} = conn) when story.type == "story" do
    story_json = ControllerHelper.format_story(story, conn)
    {200, story_json}
  end

  def get_story_response({:ok, _story}, %Plug.Conn{} = conn) do
    reason = "The provided id exists, but it doesn't correspond to a story"
    error_resp = ControllerHelper.create_error_response(reason, conn)
    {500, error_resp}
  end

  def get_story_response({:error, reason}, %Plug.Conn{} = conn) do
    error_resp = ControllerHelper.create_error_response(reason, conn)
    {404, error_resp}
  end

  def get_story_response({:error, %HTTPoison.Error{} = error}, %Plug.Conn{} = conn) do
    reason_string = HTTPoison.Error.message(error)
    error_resp = ControllerHelper.create_error_response(reason_string, conn)
    {500, error_resp}
  end




end
