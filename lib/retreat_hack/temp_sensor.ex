defmodule RetreatHack.TempSensor do

  alias Circuits.I2C

  def initialize() do
    {:ok, ref} = I2C.open("i2c-1")
    check_calibration_bit(ref)
    initiate_reading(ref)
    :timer.sleep(100)
    read_results(ref)
  end

  def check_calibration_bit(ref) do
    I2C.write(ref, 0x38, <<0x71>>)
    {:ok, <<stuff::size(4), cal_bit::size(1), rest::size(3)>>} = I2C.read(ref, 0x38, 1)
    if cal_bit != 1 do
      I2C.write(ref, 0x38, <<0xBE>>)
      :timer.sleep(20)
    end
  end

  def initiate_reading(ref) do
    I2C.write(ref, 0x38, <<0xAC, 0x33, 0x00>>)
  end

  def read_results(ref) do
    {:ok, <<status, humidity::size(20), temperature::size(20), checksum>>} = I2C.read(ref, 0x38, 7)
    IO.inspect(status, label: "status")
    IO.inspect(humidity, label: "humidity")
    IO.inspect(temperature, label: "temperature")
    IO.inspect(checksum, label: "checksum")
    IO.inspect(convert_humidity(humidity), label: "converted hum")
    IO.inspect(convert_temperature(temperature), label: "converted temp")
  end

  def convert_humidity(raw_humidity) do
    (raw_humidity / :math.pow(2, 20)) * 100
  end

  def convert_temperature(raw_temp) do
    ((raw_temp / :math.pow(2, 20)) * 200) - 50
  end

end
