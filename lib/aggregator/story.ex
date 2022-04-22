defmodule Aggregator.Story do
  defstruct by: "",
            descendants: nil,
            id: nil,
            kids: [],
            score: nil,
            time: nil,
            title: "",
            type: "",
            url: ""

  @type t :: %Aggregator.Story{
          by: binary(),
          descendants: list(),
          id: integer(),
          kids: list(),
          score: integer(),
          time: integer(),
          title: binary(),
          type: binary(),
          url: binary()
        }
end
