defmodule Codebeam2025.ImportAirports do
  alias Codebeam2025.Airports

  def import_airports() do
    File.stream!("#{__DIR__}/../../data/airports.csv")
    |> CSV.decode()
    |> Enum.to_list()
    |> convert_to_map_list()
    |> Enum.each(fn attrs ->
      {:ok, _airport} = create_airport(attrs |> atomize_keys())
    end)
  end

  defp convert_to_map_list([{:ok, header_row} | data_tuples]) do
    Enum.map(data_tuples, fn {_, data} ->
      header_row |> Enum.zip(data) |> Enum.into(%{})
    end)
  end

  defp create_airport(%{latitude_deg: lat, longitude_deg: lng} = attrs) do
    attrs
    |> Map.put(:geo_location, %Geo.Point{coordinates: {to_float(lng), to_float(lat)}})
    |> Airports.create_airport()
  end

  @spec atomize_keys(any) :: any
  def atomize_keys(%{__struct__: _} = map), do: map

  def atomize_keys(map) when is_map(map),
    do:
      Map.new(map, fn {k, v} ->
        {
          atomize_key(k),
          atomize_keys(v)
        }
      end)

  def atomize_keys(map), do: map

  defp atomize_key(key) when is_bitstring(key), do: String.to_atom(key)
  defp atomize_key(key), do: key

  defp to_float(value) when is_binary(value), do: Float.parse(value) |> elem(0)
  defp to_float(value), do: value
end
