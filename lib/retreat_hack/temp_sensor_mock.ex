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
  def handle_info(:get_sensor_readings, _) do
    Logger.info("Processing sensor readings")

    {:ok, humidity, temperature} = do_work()
    schedule_work()
    state =
      %{}
      |> Map.put(:humidity, humidity)
      |> Map.put(:temperature, temperature)
    {:noreply, state}
  end

  @impl TempSensorBehavior
  def connect() do
    {:ok, "abc"}
  end

  @impl TempSensorBehavior
  def get_humidity(_) do
    {:ok, :rand.uniform() * (100.0)}
  end

  @impl TempSensorBehavior
  def get_temperature(_) do
    {:ok, :rand.uniform() * (50.0)}
  end

  defp do_work() do
    {:ok, hum} = get_humidity("abc")
    humidity = Float.to_string(hum)
    {:ok, temp} = get_temperature("abc")
    temperature = Float.to_string(temp)
    Logger.info("Humidity: " <> humidity)
    Logger.info("Temperature: " <> temperature)
    {:ok, humidity, temperature}
  end

  defp schedule_work do
    Logger.info("Scheduling next sensor event")
    Process.send_after(self(), :get_sensor_readings, :timer.seconds(5))
  end

end
