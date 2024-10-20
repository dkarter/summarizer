defmodule Summerizer.SummarizerSupervisor do
  @moduledoc false
  use Supervisor

  alias Summerizer.EventCollector
  alias Summerizer.EventFlusher

  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @impl Supervisor
  def init(init_args) do
    children = [
      {EventCollector, init_args},
      {EventFlusher, init_args}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
