defmodule KafkaTest.TrackingConsumer do

  use KafkaEx.GenConsumer

  alias KafkaEx.Protocol.Fetch.Message

  require Logger

  def supervisor_options, do: [
    gen_consumer_impl(),
    consumer_group_name(),
    topic_names(),
    consumer_group_opts()
  ]
  defp gen_consumer_impl, do: __MODULE__
  defp consumer_group_name, do: "tracking_locations"
  defp topic_names, do: ["com.quiqup.tracking_locations"]
  defp consumer_group_opts, do: [
    heartbeat_interval: 1_000,
    commit_interval: 1_000,
    name: ConsumerGroup.TrackingLocation,
    gen_server_opts: [name: ConsumerGroup.TrackingLocation.Manager],
  ]

  def handle_message_set(message_set, state) do
    for %Message{value: message} <- message_set do
      Logger.debug(fn -> "message: " <> inspect(message) end)
    end
    {:async_commit, state}
  end
end
