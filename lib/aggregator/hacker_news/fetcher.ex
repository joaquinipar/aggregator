defmodule Aggregator.HackerNews.Fetcher do

  # Aggregator.HackerNews.Fetcher.get_50_best_stories()
  @behaviour Aggregator.HackerNews.API

  require Logger

  @impl true
  def get_50_best_stories do
    case get_stories() do
      {:ok, %HTTPoison.Response{body: stories_string}} when is_binary(stories_string) ->
        stories = Poison.decode!(stories_string)
        Logger.info("Got 50 stories!")
        Enum.take(stories, 50)
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("There was an error fetching the stories. Reason: #{reason}")
        []
      _unexpected ->
        Logger.error("Unexpected message. Expected stories list.")
        [] # ?????
    end
  end

  @impl true
  def get_story(id) do
    "#{get_api_url()}item/#{id}.json"
    |> HTTPoison.get
  end

  defp get_stories do
    get_api_url() <> "topstories.json"
    |> HTTPoison.get
  end

  defp get_api_url do
    Application.get_env(:aggregator, :api_url)
  end

end
