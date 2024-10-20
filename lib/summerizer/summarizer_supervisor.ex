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
    partitions = 3

    children = [
      {
        PartitionSupervisor,
        child_spec: EventCollector.child_spec(init_args),
        name: EventCollectorPartitionSupervisor,
        partitions: partitions
      },
      {
        PartitionSupervisor,
        # modify the options that are passed to the partitioned process to
        # inject a partition number
        child_spec: EventFlusher.child_spec(init_args),
        name: EventFlusherPartitionSupervisor,
        partitions: partitions,
        with_arguments: fn [opts], partition ->
          [Keyword.put(opts, :partition, partition)]
        end
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
