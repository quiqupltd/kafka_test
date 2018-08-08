defmodule KafkaTest.KafkaMonitor do
  use GenServer
  require Logger

  @restart_wait_seconds 1
  @retry_produce_seconds 1

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Process.send(self(), :start_worker, [])

    {:ok, %{worker_ref: nil}}
  end

  @impl true
  def handle_info(:start_worker, %{worker_ref: worker_ref}) do
    Application.start(:kafka_ex)

    case KafkaEx.create_worker(:kafka_ex, consumer_group: :no_consumer_group) do
      {:ok, pid} ->
        Logger.info("Monitoring KafkaEx worker at " <> inspect(pid))
        Process.monitor(pid)

        KafkaTest.ConsumerSupervisor.start_consumer()

        {:noreply, %{worker_ref: pid}}

      {:error, {:already_started, pid}} ->
        Logger.info("KafkaEx worker already running at " <> inspect(pid))
        Process.monitor(pid)

        KafkaTest.ConsumerSupervisor.start_consumer()

        {:noreply, %{worker_ref: pid}}

      {:error, error} ->
        Logger.warn("KafkaEx worker failed to start. Restarting in #{@restart_wait_seconds} seconds...")
        Logger.debug(inspect(error))
        Process.send_after(self(), :start_worker, @restart_wait_seconds * 1000)

        {:noreply, %{worker_ref: nil}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{worker_ref: worker_ref}) do
    if ref == worker_ref do
      Logger.warn("KafkaEx worker went down. Restarting in #{@restart_wait_seconds} seconds...")
      Process.send_after(self(), :start_worker, @restart_wait_seconds * 1000)
      {:noreply, {worker_ref}}
    else
      Logger.warn("KafkaEx other")
      Process.send_after(self(), :start_worker, @restart_wait_seconds * 1000)
      {:noreply, {worker_ref}}
    end
  end
end
