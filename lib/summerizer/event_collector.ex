defmodule Summerizer.EventCollector do
  @moduledoc false
  use GenServer

  alias Summerizer.User

  require Logger

  defstruct count: 0,
            data: %{}

  # --- Client API ---

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def record_event(%User{} = user) do
    user.id
    |> via_tuple()
    |> GenServer.cast({:record_event, user})
  end

  def flush_events(partition) do
    partition
    |> via_tuple()
    |> GenServer.call(:flush_events)
  end

  # --- server callbacks

  @impl GenServer
  def init(_) do
    {:ok, %__MODULE__{}}
  end

  @impl GenServer
  def handle_cast({:record_event, %User{} = user}, %__MODULE__{} = state) do
    data = Map.update(state.data, user.id, 1, &(&1 + 1))

    {:noreply, %__MODULE__{count: state.count + 1, data: data}}
  end

  @impl GenServer
  def handle_call(:flush_events, _from, state) do
    if state.count > 0 do
      Logger.info("#{__MODULE__}:#{inspect(self())} - #{state.count} events flushed")
    end

    {:reply, state.data, %__MODULE__{}}
  end

  defp via_tuple(term) do
    {:via, PartitionSupervisor, {EventCollectorPartitionSupervisor, term}}
  end
end
