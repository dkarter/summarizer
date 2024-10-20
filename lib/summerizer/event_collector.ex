defmodule Summerizer.EventCollector do
  @moduledoc false
  use GenServer

  alias Summerizer.User

  require Logger

  defstruct count: 0,
            data: %{}

  # --- Client API ---

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def record_event(%User{} = user) do
    GenServer.cast(__MODULE__, {:record_event, user})
  end

  def flush_events do
    GenServer.call(__MODULE__, :flush_events)
  end

  # --- server callbacks

  @impl GenServer
  def init(_) do
    {:ok, %__MODULE__{}}
  end

  @impl GenServer
  def handle_cast({:record_event, %User{} = user}, state) do
    data = Map.update(state.data, user.id, 1, &(&1 + 1))

    {:noreply, %{state | data: data}}
  end

  @impl GenServer
  def handle_call(:flush_events, _from, state) do
    if state.count > 0 do
      Logger.info("#{__MODULE__} - #{state.count} events flushed")
    end

    {:reply, state.data, %__MODULE__{}}
  end
end
