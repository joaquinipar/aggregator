defmodule Aggregator.HackerNewsWeb.ControllerHelper do

  use Scrivener

  alias Aggregator.HackerNewsWeb.HalHelper

  @spec get_full_url(Plug.Conn.t()) :: binary()
  def get_full_url(%Plug.Conn{} = conn) do
    get_url(conn) <> "?" <> conn.query_string
  end


  @spec get_url(Plug.Conn.t()) :: binary()
  def get_url(%Plug.Conn{} = conn) do
    Atom.to_string(conn.scheme) <> "://" <> conn.host <> ":" <> Integer.to_string(conn.port) <> conn.request_path
  end

  @spec format_story(Aggregator.Story.t(), Plug.Conn.t()) :: binary()
  def format_story( %Aggregator.Story{} = story, %Plug.Conn{} = conn) do
    story
    |> HalHelper.format_single_page(conn)
    |> Poison.encode!
  end

  @spec create_error_response(binary(), Plug.Conn.t()) :: binary()
  def create_error_response(reason, %Plug.Conn{} = conn) do
    reason
    |> HalHelper.format_single_page_error(conn)
    |> Poison.encode!
  end

  @spec paginate_stories(list(Aggregator.Story.t()), map()) :: Scrivener.Page.t()
  def paginate_stories(stories, %{"page" => page_number, "page_size" => page_size} = _params) do
    Scrivener.paginate(stories,%{page: page_number, page_size: page_size})
  end

  def paginate_stories(stories, %{"page" => page_number} = _params) do
    Scrivener.paginate(stories,%{page: page_number, page_size: 10})
  end

  def paginate_stories(stories, %{} = _params) do
    Scrivener.paginate(stories,%{page: 1, page_size: 10})
  end
end
