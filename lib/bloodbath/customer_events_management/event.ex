defmodule Bloodbath.CustomerEventsManagement.Event do
  import Ecto.Changeset
  import Ecto.Query, warn: false
  use Ecto.Schema
  alias Bloodbath.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    belongs_to :person, Bloodbath.AccountManagement.Person
    belongs_to :organization, Bloodbath.AccountManagement.Organization
    field :scheduled_for, :utc_datetime
    field :enqueued_at, :utc_datetime
    field :locked_at, :utc_datetime
    field :dispatched_at, :utc_datetime
    field :method, Ecto.Enum, values: [:get, :post, :put, :patch, :delete]
    field :origin, :string
    field :headers, :string
    field :payload, :string
    field :endpoint, :string

    timestamps()
  end

  def create_changeset(event, attrs) do
    event
    |> cast(attrs, [:scheduled_for, :origin, :method, :headers, :payload, :endpoint])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
    |> validate_required([:scheduled_for, :origin, :method, :headers, :endpoint])
    |> check_methods_with_payload(attrs)
    |> check_format_for_headers(attrs)
  end

  def update_changeset(event, attrs) do
    event
    |> cast(attrs, [:enqueued_at, :locked_at, :dispatched_at])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
  end

  defp check_methods_with_payload(changeset, attrs) do
    if attrs.method in ["get", "delete"] && Map.has_key?(attrs, :payload) do
      add_error(changeset, :payload, "can't be set using the #{attrs.method} method")
    else
      changeset
    end
  end

  defp check_format_for_headers(changeset, attrs) do
    try do
      Poison.decode!(attrs.headers)
      changeset
    rescue
      Poison.ParseError -> add_error(changeset, :headers, "format isn't valid, it should be a JSON. Please check https://www.notion.so/loschcode/What-format-use-for-the-headers-d84e63e2d8ab482cab0d60e55a3e1581 for more information.")
    end
  end
end
