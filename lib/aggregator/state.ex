defmodule Aggregator.State do
  defstruct stories: [],
            stories_content: [],
            refresh_interval: :timer.seconds(10),
            ids_ref: nil,
            content_ref: nil

  @type t :: %Aggregator.State{
          stories: list(integer()),
          stories_content: list(),
          refresh_interval: integer(),
          ids_ref: reference(),
          content_ref: reference()
        }
end
