defmodule KafkaTest.Application do
  use Application

  def start(_type, _args) do
    self() |> IO.inspect(label: "#{__MODULE__}.start1")

    kafka_genconsumers = [
      %{
        id: KafkaTest.TrackingConsumer,
        start: {KafkaEx.ConsumerGroup, :start_link, [KafkaTest.TrackingConsumer, "tracking_locations", ["com.quiqup.tracking_locations"]]}
      }
    ]

    children = [
      {SigstrKafkaMonitor, kafka_genconsumers}
    ]

    opts = [strategy: :one_for_one, name: KafkaTest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
