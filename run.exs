alias Summerizer.EventCollector
alias Summerizer.EventFlusher
alias Summerizer.SummarizerSupervisor
alias Summerizer.User

SummarizerSupervisor.start_link(flush_interval: 1_000)

test_users = [
  %User{id: "1", name: "MegaCorp", plan: :enterprise},
  %User{id: "2", name: "Gundam", plan: :basic},
  %User{id: "3", name: "CoffeeCentral", plan: :free},
  %User{id: "4", name: "CodeTogether", plan: :enterprise},
  %User{id: "5", name: "FPFunHouse", plan: :basic}
]

1..100_000
|> Task.async_stream(
  fn _ ->
    user = Enum.random(test_users)
    EventCollector.record_event(user)
  end,
  max_concurrency: 2_000
)
|> Stream.run()
