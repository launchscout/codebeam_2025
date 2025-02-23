defmodule Codebeam2025.Airports do
  @moduledoc """
  The Airports context.
  """

  import Ecto.Query, warn: false
  alias Codebeam2025.Repo

  alias Codebeam2025.Airports.Airport

  def get_airport_by_code(code) do
    Repo.get_by(Airport, ident: code)
  end

  @doc """
  Returns the list of airports.

  ## Examples

      iex> list_airports()
      [%Airport{}, ...]

  """
  def list_airports do
    Repo.all(Airport)
  end

  def list_airports_in_bounds(%{north: north, east: east, west: west, south: south}) do
    bounds_query =
      from a in Airport,
        where:
          fragment(
            "? && ST_MakeEnvelope(?, ?, ?, ?)",
            a.geo_location,
            ^east,
            ^north,
            ^west,
            ^south
          )

    Repo.all(bounds_query)
  end

  @doc """
  Gets a single airport.

  Raises `Ecto.NoResultsError` if the Airport does not exist.

  ## Examples

      iex> get_airport!(123)
      %Airport{}

      iex> get_airport!(456)
      ** (Ecto.NoResultsError)

  """
  def get_airport!(id), do: Repo.get!(Airport, id)

  @doc """
  Creates a airport.

  ## Examples

      iex> create_airport(%{field: value})
      {:ok, %Airport{}}

      iex> create_airport(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_airport(attrs \\ %{}) do
    %Airport{}
    |> Airport.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a airport.

  ## Examples

      iex> update_airport(airport, %{field: new_value})
      {:ok, %Airport{}}

      iex> update_airport(airport, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_airport(%Airport{} = airport, attrs) do
    airport
    |> Airport.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a airport.

  ## Examples

      iex> delete_airport(airport)
      {:ok, %Airport{}}

      iex> delete_airport(airport)
      {:error, %Ecto.Changeset{}}

  """
  def delete_airport(%Airport{} = airport) do
    Repo.delete(airport)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking airport changes.

  ## Examples

      iex> change_airport(airport)
      %Ecto.Changeset{data: %Airport{}}

  """
  def change_airport(%Airport{} = airport, attrs \\ %{}) do
    Airport.changeset(airport, attrs)
  end

  @doc """
  Searches airports by name or code (ident).
  Returns a list of airports that match the search term.

  ## Examples

      iex> search_airports("London")
      [%Airport{}, ...]

  """
  def search_airports(search_term) when is_binary(search_term) do
    search_pattern = "%#{search_term}%"

    query =
      from a in Airport,
        where: ilike(a.name, ^search_pattern) or ilike(a.ident, ^search_pattern),
        where: not is_nil(a.iata_code),
        limit: 20

    Repo.all(query)
  end

  def search_airports(_), do: []
end
