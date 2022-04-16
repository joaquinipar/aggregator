defmodule Aggregator.Stories do
  @doc """
  Handles the state of the application and fetches the API every X minutes for new stories.
  """

  @name :stories_genserver

  require Logger

  use GenServer

  alias Aggregator.Fetcher

  defmodule State do
    defstruct stories: [], stories_content: [], refresh_interval: :timer.seconds(10), ids_ref: nil, content_ref: nil
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
    stories_ids = Fetcher.get_50_best_stories()
    stories_content = get_content_from_ids(stories_ids)
    schedule_refresh(state.refresh_interval)
    {:ok, %State{stories: stories_ids, stories_content: stories_content}}
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
    {:reply, state.stories_content, state}
  end

  @doc """
  Sets a new refresh inteval.
  """
  def handle_call({:set_refresh_interval, miliseconds}, state) do
    {:reply, :ok, %State{ state | refresh_interval: miliseconds}}
  end

  @doc """
  :refresh -> Refresh the state with the new top 50 stories and schedules a new refresh after the interval.
  {ref, top_stories} -> Receives the result of the Fetch async_nolink task matching with the saved ref.
  Triggers fetch of the content of each respective story using its id.
  {ref, {stories_ids, stories_content}} -> Receives both the stories id list and the content list and finally
  saves into the state.
  """
  def handle_info(:refresh, %State{} = state) do
    Logger.info("Refreshing stories...")

    # Fetching the top_stories as non blocking operations
    task_ids = Task.Supervisor.async_nolink(Task.FetchSupervisor,&Fetcher.get_50_best_stories/0)

    # Scheduling refresh
    schedule_refresh(state.refresh_interval)

    # Saving nolink task refs for matching them when the task sends its result
    {:noreply, %State{state | ids_ref: task_ids.ref}}
  end

  def handle_info({ref, top_stories}, %State{ids_ref: ref} = state) do
    # Getting rid of the DOWN message
    Process.demonitor(ref, [:flush])

    # Creating an non blocking operation that fetches the stories content asynchcronically
    multitask = Task.Supervisor.async_nolink(Task.FetchSupervisor,
    fn ->
      contents = get_content_from_ids(top_stories)
      {top_stories, contents}
   end)

    # Saving nolink task refs for matching them when the task sends its result
    {:noreply, %State{state | content_ref: multitask.ref}}
  end

  def handle_info({ref, {stories_ids, stories_content}}, %State{content_ref: ref} = state) do
    # Getting rid of the DOWN message
    Process.demonitor(ref, [:flush])
    Logger.info("Stories were refreshed successfully!")
    # Saving both the stories_id and stories_content at the same moment to avoid having inconsistent state for short periods of time
    {:noreply, %State{state | stories: stories_ids, stories_content: stories_content}}
  end

  defp get_content_from_ids(top_stories) do
    top_stories
    |> Enum.map(&Task.async(fn -> Fetcher.get_story(&1) end))
    |> Enum.map(&Task.await(&1))
    |> Enum.map(fn {:ok, res} -> res.body end)
    |> Enum.map(fn body_json -> String.replace(body_json, "\n", " ") end) # workaround fail encode when string has '\n'
    |> Enum.map(&Poison.decode!/1)
  end
end
