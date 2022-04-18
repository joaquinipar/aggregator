defmodule Aggregator.HalHelper do

  alias HAL.{Document, Link, Embed}
  alias Aggregator.EndpointHelper

  def format_page(%Scrivener.Page{} = page, %Plug.Conn{} = conn) do
    base_url = EndpointHelper.get_url(conn)
    url = EndpointHelper.get_full_url(conn)

    %Document{}
    |> Document.add_link(%Link{rel: "self", href: url, title: "self"})
    |> Document.add_link(%Link{rel: "first", href: "#{base_url}?page=1&page_size=#{page.page_size}", title: "first"})
    |> Document.add_link(%Link{rel: "last", href: "#{base_url}?page=#{page.total_pages}&page_size=#{page.page_size}", title: "last"})
    |> add_prev(url, page)
    |> add_next(base_url, page)
    |> Document.add_property(:page_number, page.page_number)
    |> Document.add_property(:page_size, page.page_size)
    |> Document.add_property(:total_entries, page.total_entries)
    |> Document.add_property(:total_pages, page.total_pages)
    |> Document.add_embed(%Embed{resource: "top_stories", embed: page.entries})
  end

  def format_single_page(%Aggregator.Story{} = story, %Plug.Conn{} = conn) do
    url = EndpointHelper.get_full_url(conn)

    %Document{}
    |> Document.add_link(%Link{rel: "self", href: url, title: "self"})
    |> Document.add_embed(%Embed{resource: "story", embed: story})
  end

  def format_single_page_error(reason, %Plug.Conn{} = conn) do
    url = EndpointHelper.get_full_url(conn)
    IO.puts "reason #{reason}"
    %Document{}
    |> Document.add_link(%Link{rel: "self", href: url, title: "self"})
    |> Document.add_property(:error, reason)
  end

  def format_page_json(%Scrivener.Page{} = page, conn) do
    format_page(page, conn)
    |> Poison.encode!
  end

  defp add_prev(%Document{} = document, _url, %Scrivener.Page{page_number: 1}) do
    document
  end

  defp add_prev(%Document{} = document, url, %Scrivener.Page{page_number: page_number}) do
    document
    |> Document.add_link(%Link{rel: "prev", href: "#{url}?page=#{page_number - 1}", title: "prev"})
  end

  defp add_next(%Document{} = document, _url, %Scrivener.Page{page_number: total, total_pages: total}) do
    document
  end

  defp add_next(%Document{} = document, base_url, %Scrivener.Page{} = page) do
    document
    |> Document.add_link(%Link{rel: "next", href: "#{base_url}?page=#{page.page_number + 1}&page_size=#{page.page_size}", title: "next"})
  end

end
