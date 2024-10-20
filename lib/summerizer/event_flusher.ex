defmodule Summerizer.EventFlusher do
  @moduledoc false
  use GenServer

  alias Summerizer.EventCollector

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # server callbacks -----------
  #
  @impl GenServer
  def init(opts) do
    flush_interval = Keyword.fetch!(opts, :flush_interval)

    {:ok, flush_interval, {:continue, :schedule_next_run}}
  end

  @impl GenServer
  def handle_continue(:schedule_next_run, flush_interval) do
    Process.send_after(self(), :perform_cron_work, flush_interval)

    {:noreply, flush_interval}
  end

  @impl GenServer
  def handle_info(:perform_cron_work, flush_interval) do
    write_data_to_db = EventCollector.flush_events()

    if map_size(write_data_to_db) != 0 do
      Logger.info(write_data_to_db)
    end

    {:noreply, flush_interval, {:continue, :schedule_next_run}}
  end
end
