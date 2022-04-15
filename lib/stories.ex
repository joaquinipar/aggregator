defmodule Aggregator.Stories do
  @doc """
  Handles the state of the application and fetches the API every X minutes for new stories.
  """

  @name :stories_genserver

  use GenServer

  alias Aggregator.Fetcher

  defmodule State do
    defstruct stories: [], refresh_interval: :timer.minutes(5)
  end

  # Client Interface

  def start_link(_arg) do
    IO.puts "Starting the Stories process.."
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  @doc """
  Gets the top 50 stories from the stored state.
  """
  def get_stories do
    GenServer.call @name, :get_stories
  end

  @doc """
  Changes the refresh interval after the next refresh.
  """
  def set_refresh_interval(miliseconds) do
    GenServer.call @name, {:set_refresh_interval, miliseconds}
  end

  # Server Callbacks

  @doc """
  Saves the initial state and schedules a refresh to update the state after the default interval passed.
  """
  def init( %State{} = state) do
    new_state = Fetcher.get_50_best_stories()
    schedule_refresh(state.refresh_interval)
    {:ok, %State{stories: new_state}}
  end

  @doc """
  Sends a :refresh message after the passed interval.
  """
  def schedule_refresh(interval) do
    Process.send_after(self(), :refresh, interval)
  end

  @doc """
  Gets the top 50 stories from the state.
  """
  def handle_call(:get_stories, _from, %State{} = state) do
    {:reply, state.stories, state}
  end

  @doc """
  Sets a new refresh inteval.
  """
  def handle_call({:set_refresh_interval, miliseconds}, state) do
    {:reply, :ok, %State{ state | refresh_interval: miliseconds}}
  end

  @doc """
  Refresh the state with the new top 50 stories and schedules a new refresh after the interval.
  """
  def handle_info(:refresh, %State{} = state) do
    new_state = Fetcher.get_50_best_stories()
    schedule_refresh(state.refresh_interval)
    {:noreply, %State{ state |stories: new_state}}
  end

end
