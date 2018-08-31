defmodule KafkaTest.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    kafka_genconsumers = [
      %{
        id: KafkaTest.TrackingConsumer,
        start: {KafkaEx.ConsumerGroup, :start_link, [KafkaTest.TrackingConsumer, "tracking_locations", ["com.quiqup.tracking_locations"]]}
      }
    ]

    children = [
      worker(KafkaTest.KafkaMonitor, [[]]),
      worker(KafkaTest.ConsumerSupervisor, [kafka_genconsumers]),
    ]

    opts = [strategy: :rest_for_one, name: KafkaTest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
