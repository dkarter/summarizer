defmodule Summerizer.EventFlusher do
  @moduledoc false
  use GenServer

  alias Summerizer.EventCollector

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  # server callbacks -----------
  #
  @impl GenServer
  def init(opts) do
    state = %{
      flush_interval: Keyword.fetch!(opts, :flush_interval),
      partition: Keyword.fetch!(opts, :partition)
    }

    {:ok, state, {:continue, :schedule_next_run}}
  end

  @impl GenServer
  def handle_continue(:schedule_next_run, state) do
    Process.send_after(self(), :perform_cron_work, state.flush_interval)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:perform_cron_work, state) do
    write_data_to_db = EventCollector.flush_events(state.partition)

    if map_size(write_data_to_db) != 0 do
      Logger.info("#{__MODULE__}:#{inspect(self())} - Flushed data: #{inspect(write_data_to_db)}")
    end

    {:noreply, state, {:continue, :schedule_next_run}}
  end
end
