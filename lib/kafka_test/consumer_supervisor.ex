defmodule KafkaTest.ConsumerSupervisor do
  @moduledoc """
  A supervisor that monitors consumers
  """

  # use DynamicSupervisor
  # use Supervisor
  use GenServer
  require Logger

  def start_link(opts) do
    opts |> IO.inspect(label: "opts")
    # DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    # Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # DynamicSupervisor.init(strategy: :one_for_one)

    # # Process.monitor(pid)

    # # supervise(children, strategy: :simple_one_for_one)

    # # Supervisor.start_link(children, opts)

    {:ok, %{worker_ref: nil}}
  end

  def start_consumer do
    import Supervisor.Spec

    Logger.info("Starting consumer")

    # children = [
    #   # KafkaTest.TrackingConsumer
    #   # worker(KafkaTest.TrackingConsumer, [], restart: :temporary)
    #   supervisor(KafkaEx.ConsumerGroup, KafkaTest.TrackingConsumer.supervisor_options),
    # ]

    # opts = [strategy: :one_for_one, name: KafkaTest.Supervisor]
    # Supervisor.init(children, opts)

    Kernel.apply(KafkaEx.ConsumerGroup, :start_link, KafkaTest.TrackingConsumer.supervisor_options)
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    Logger.warn("foo")
  end

  # def start(opts), do: supervise(opts)
  # defp supervise(opts), do: Supervisor.start_child(__MODULE__, [opts])

  # def handle(id) do

  # end

  # @doc """
  # Starts a `GameServer` process and supervises it.
  # """
  # def new(id) do
  #   child_spec = %{
  #     id: GameServer,
  #     start: {GameServer, :start_link, [id]},
  #     restart: :transient
  #   }

  #   DynamicSupervisor.start_child(__MODULE__, child_spec)
  # end

  # @doc """
  # Terminates the `GameServer` process normally. It won't be restarted.
  # """
  # def stop_game(game_name) do
  #   :ets.delete(:games_table, game_name)

  #   child_pid = GameServer.game_pid(game_name)
  #   DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  # end
end
