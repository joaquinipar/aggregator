defmodule Aggregator.HackerNews.API do

  @callback get_50_best_stories() :: list(integer)
  @callback get_story(id :: integer()) :: {:ok, map()}
end
