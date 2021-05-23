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
    field :origin, Ecto.Enum, values: [:graphql_api, :rest_api]
    field :headers, :string
    field :body, :string
    field :endpoint, :string

    timestamps([type: :utc_datetime_usec])
  end

  def create_changeset(event, attrs) do
    event
    |> cast(attrs, [:scheduled_for, :origin, :method, :headers, :body, :endpoint])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
    |> validate_required([:scheduled_for, :origin, :method, :headers, :endpoint])
    |> check_methods_with_body(attrs)
    |> check_format_for_headers(attrs)
  end

  def update_changeset(event, attrs) do
    event
    |> cast(attrs, [:enqueued_at, :locked_at, :dispatched_at])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
  end

  defp check_methods_with_body(changeset, attrs) do
    if attrs.method in ["get", "delete"] && Map.has_key?(attrs, :body) do
      add_error(changeset, :body, "can't be set using the #{attrs.method} method")
    else
      changeset
    end
  end

  defp check_format_for_headers(changeset, attrs) do
    try do
      Poison.decode!(attrs.headers)
      changeset
    rescue
      Poison.ParseError -> add_error(changeset, :headers, "format isn't valid, it should be a JSON. Please check https://www.notion.so/loschcode/What-s-the-correct-format-to-build-headers-b1507f32ed3f4bd0abfe5ea6f896c9fe for more information.")
    end
  end
end
