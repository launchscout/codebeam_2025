defmodule Codebeam2025Web.AirportMapLive do
  alias Codebeam2025.Airports.Airport
  use Codebeam2025Web, :live_view

  use LiveElements.CustomElementsHelpers

  custom_element :autocomplete_input,
    events: ["autocomplete-search", "autocomplete-commit"]

  alias Codebeam2025.Airports

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       airports: [],
       api_key: Application.get_env(:codebeam_2025, :api_key),
       airport: nil,
       favorite_airport: nil,
       form: to_form(%{"airport_code" => ""})
     )}
  end

  @impl true
  def handle_event("autocomplete-search", %{"name" => "airport_code", "query" => query}, socket) do
    {:noreply, socket |> assign(:airports, Airports.search_airports(query))}
  end

  def handle_event("autocomplete-commit", %{"name" => "airport_code", "value" => value}, socket) do
    {:noreply,
     socket
     |> assign(:airport, Airports.get_airport_by_code(value))
     |> assign(:airports, [])}
  end

  def handle_event("choose_favorite", %{"airport_code" => airport_code}, socket) do
    airport = Airports.get_airport_by_code(airport_code)
    {:noreply, socket |> assign(:favorite_airport, airport) |> assign(:airport, airport) |> assign(:airports, [])}
  end

  @impl true
  def handle_event(_event, _params, socket), do: {:noreply, socket}

  defp coordinates(%Airport{geo_location: %Geo.Point{coordinates: {lng, lat}}}),
    do: "#{lat}, #{lng}"

  defp options_for(airports) do
    airports
    |> Enum.map(fn %Airport{iata_code: code, ident: ident, name: name} ->
      %{label: "#{code} - #{name}", value: ident}
    end)
  end
end
