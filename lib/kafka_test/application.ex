defmodule KafkaTest.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    self() |> IO.inspect(label: "#{__MODULE__}.start1")

    children = [
      supervisor(KafkaEx.ConsumerGroup, KafkaTest.TrackingConsumer.supervisor_options),
    ]

    self() |> IO.inspect(label: "#{__MODULE__}.start2")

    opts = [strategy: :rest_for_one, name: KafkaTest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
