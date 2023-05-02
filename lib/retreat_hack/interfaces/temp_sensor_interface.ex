defmodule RetreatHack.Interfaces.TempSensorInterface do

  def start_link(opts) do
    temp_sensor_module().start_link(opts)
  end

  def connect() do
    temp_sensor_module().connect()
  end

  def get_temperature(ref) do
    temp_sensor_module().get_temperature(ref)
  end

  def get_humidity(ref) do
    temp_sensor_module().get_humidity(ref)
  end

  defp temp_sensor_module() do
    Application.get_env(:retreat_hack, :temp_sensor_module)
  end

end
