defmodule RetreatHack.Behaviours.TempSensorBehavior do
  @callback start_link(term) :: GenServer.on_start()
  @callback connect() :: {:ok, term}
  @callback get_humidity(term) :: {:ok, float()} | {:error, term}
  @callback get_temperature(term) :: {:ok, float()} | {:error, term}
end
