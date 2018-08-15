defmodule KafkaTest.KafkaMonitor do
  use GenServer
  require Logger

  @restart_wait_seconds 1
  @retry_produce_seconds 1

  def start_link(_opts) do
    self() |> IO.inspect(label: "#{__MODULE__}.start_link")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    self() |> IO.inspect(label: "#{__MODULE__}.init")
    Process.send(self(), :start_worker, [])

    {:ok, %{worker_ref: nil}}
  end

  @impl true
  def handle_info(:start_worker, %{worker_ref: worker_ref}) do
    self() |> IO.inspect(label: "#{__MODULE__}.handle_info")
    # Application.start(:kafka_ex)

    case KafkaEx.create_worker(:kafka_ex, consumer_group: :no_consumer_group) do
      {:ok, pid} ->
        Logger.info("#{__MODULE__} Monitoring KafkaEx worker at " <> inspect(pid))
        Process.monitor(pid)

        KafkaTest.ConsumerSupervisor.start_consumer()

        {:noreply, %{worker_ref: pid}}

      {:error, {:already_started, pid}} ->
        Logger.info("#{__MODULE__} KafkaEx worker already running at " <> inspect(pid))
        Process.monitor(pid)

        KafkaTest.ConsumerSupervisor.start_consumer()

        {:noreply, %{worker_ref: pid}}

      {:error, error} ->
        Logger.warn("#{__MODULE__} KafkaEx worker failed to start. Restarting in #{@restart_wait_seconds} seconds...")
        Logger.debug(inspect(error))
        Process.send_after(self(), :start_worker, @restart_wait_seconds * 1000)

        {:noreply, %{worker_ref: nil}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{worker_ref: worker_ref}) do
    if ref == worker_ref do
      Logger.warn("#{__MODULE__} KafkaEx worker went down. Restarting in #{@restart_wait_seconds} seconds...")
      Process.send_after(self(), :start_worker, @restart_wait_seconds * 1000)
      {:noreply, {worker_ref}}
    else
      Logger.warn("#{__MODULE__} KafkaEx other")
      Process.send_after(self(), :start_worker, @restart_wait_seconds * 1000)
      {:noreply, {worker_ref}}
    end
  end
end
