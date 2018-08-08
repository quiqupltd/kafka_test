defmodule KafkaTest.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(KafkaEx.ConsumerGroup, KafkaTest.TrackingConsumer.supervisor_options),

      # KafkaTest.KafkaMonitor,
      # KafkaTest.ConsumerSupervisor
    ]

    opts = [strategy: :rest_for_one, name: KafkaTest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
