defmodule RetreatHack.TempSensorMock do
  use GenServer

  alias RetreatHack.Behaviours.TempSensorBehavior
  require Logger

  @behaviour TempSensorBehavior

  @impl GenServer
  def init(stack) do
    connect()
    schedule_work()
    {:ok, stack}
  end

  @impl TempSensorBehavior
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def handle_info(:get_sensor_readings, state) do
    Logger.info("Processing sensor readings")

    do_work()
    schedule_work()
    {:noreply, state}
  end

  @impl TempSensorBehavior
  def connect() do
    {:ok, "abc"}
  end

  @impl TempSensorBehavior
  def get_humidity(_) do
    :rand.uniform(100)
  end

  @impl TempSensorBehavior
  def get_temperature(_) do
    :rand.uniform(50)
  end

  defp do_work() do
    Logger.info("Humidity: " <> Integer.to_string(get_humidity(123)))
    Logger.info("Temperature: " <> Integer.to_string(get_temperature(123)))
  end

  defp schedule_work do
    Logger.info("Scheduling next sensor event")
    Process.send_after(self(), :get_sensor_readings, :timer.seconds(5))
  end

end
