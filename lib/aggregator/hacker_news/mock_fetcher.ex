defmodule Aggregator.HackerNews.MockFetcher do

  @behaviour Aggregator.HackerNews.API

  @impl true
  def get_50_best_stories() do
    [184, 608, 475, 112, 267, 665, 26, 406, 314, 132,
    521, 297, 584, 228, 472, 846, 251, 857, 568, 506,
    365, 910, 833, 277, 665, 475, 331, 724, 452, 418,
    909, 984, 481, 475, 456, 231, 924, 70, 962, 384,
    108, 728, 298, 450, 980, 405, 387, 728, 851, 433]
  end

  @impl true
  def get_story(id) do
    {:ok, %{
      by: "test_user",
      id: id,
      kids: [],
      parent: id - 1,
      text: "<p>This a mock story</p>",
      time: 1_314_211_127,
      type: "story"
    }}
  end
end
