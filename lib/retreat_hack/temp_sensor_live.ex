defmodule RetreatHack.TempSensorLive do
  use GenServer

  alias RetreatHack.Behaviours.TempSensorBehavior
  alias Circuits.I2C
  require Logger

  @behaviour TempSensorBehavior

  @connection_name "i2c-1"
  @command_byte 0x38
  @cal_check_command 0x71

  @impl GenServer
  def init(_) do
    {:ok, ref} = connect()
    schedule_work()
    {:ok, %{i2c_ref: ref}}
  end

  @impl TempSensorBehavior
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :temp_sensor)
  end

  @impl GenServer
  def handle_call(:get_sensor_readings, _from, %{i2c_ref: i2c} = state) do
    Logger.info("Processing sensor readings")

    {:ok, humidity, temperature} = do_work(i2c)
    {:reply, %{humidity: humidity, temperature: temperature}, state}
  end

  @impl GenServer
  def handle_info(:get_sensor_readings, %{i2c_ref: i2c} = state) do
    Logger.info("Processing sensor readings")

    {:ok, humidity, temperature} = do_work(i2c)
    schedule_work()
    state =
      state
      |> Map.put(:humidity, humidity)
      |> Map.put(:temperature, temperature)
    {:noreply, state}
  end

  @impl TempSensorBehavior
  def connect() do
    with {:ok, ref} <- I2C.open(@connection_name) do
      check_calibration_bit(ref)
      {:ok, ref}
    else
      {:error, _} ->
        {:error, "Could not open I2C connection"}
    end
  end

  @impl TempSensorBehavior
  def get_humidity(ref) do
    with {:ok, <<status, humidity::size(20), temperature::size(20), checksum>>} <-
       get_reading(ref)
    do
      convert_humidity(humidity)
    end
  end

  @impl TempSensorBehavior
  def get_temperature(ref) do
    with {:ok, <<status, humidity::size(20), temperature::size(20), checksum>>} <-
       get_reading(ref)
    do
      convert_temperature(temperature)
    end
  end

  defp check_calibration_bit(ref) do
    with :ok <- I2C.write(ref, @command_byte, <<@cal_check_command>>),
      {:ok, <<stuff::size(4), cal_bit::size(1), rest::size(3)>>} <-
        I2C.read(ref, @command_byte, 1) do
      if cal_bit != 1 do
        I2C.write(ref, @command_byte, <<0xBE>>)
        :timer.sleep(20)
      end
    end
  end

  defp get_reading(ref) do
    I2C.write(ref, @command_byte, <<0xAC, 0x33, 0x00>>)
    :timer.sleep(150)
    I2C.read(ref, 0x38, 7)
  end

  defp convert_humidity(raw_humidity) do
    (raw_humidity / :math.pow(2, 20)) * 100
  end

  defp convert_temperature(raw_temp) do
    ((raw_temp / :math.pow(2, 20)) * 200) - 50
  end

  defp do_work(i2c) do
    humidity = Float.to_string(get_humidity(i2c))
    temperature = Float.to_string(get_temperature(i2c))
    Logger.info("Humidity: " <> humidity)
    Logger.info("Temperature: " <> temperature)
    {:ok, humidity, temperature}
  end

  defp schedule_work do
    Logger.info("Scheduling next sensor event")
    Process.send_after(self(), :get_sensor_readings, :timer.seconds(5))
  end
end
