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
    # "2021-05-26T17:27:36-05:00" -> from DateTime.now.to_s (ISO 8601)
    # "2021-05-26 00:27:23 +0200" -> from 1.days.ago.to_s

    # TODO also: ADD TESTS ON THE BACKEND FOR THIS, IT'S QUITE AN IMPORTANT PIECE
    # ALSO ADD TESTS FOR THE DIFFERENT HEADERS FORMAT IF POSSIBLE
    normalized_attributes = attrs
    |> normalize_headers
    |> normalize_scheduled_for

    basic_validation = event
    |> cast(normalized_attributes, [:scheduled_for, :origin, :method, :headers, :body, :endpoint])
    |> validate_required([:scheduled_for, :origin, :method, :headers, :endpoint])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)

    if basic_validation.valid? do
      basic_validation
      |> check_methods_with_body(normalized_attributes)
      |> check_and_adapt_format_for_headers(normalized_attributes)
      |> check_scheduled_for_in_the_past(normalized_attributes)
    else
      basic_validation
    end
  end

  def update_changeset(event, attrs) do
    event
    |> cast(attrs, [:enqueued_at, :locked_at, :dispatched_at])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
  end

  # because headers can be received in string format (cURL) or in tuple (libraries)
  # we normalize it before going further (this can be extended to other params if need be)
  defp normalize_headers(attrs = %{ headers: headers }) when is_map(headers) do
    encoded_headers = Poison.encode!(headers)
    attrs |> Map.merge(%{headers: encoded_headers})
  end
  defp normalize_headers(attrs), do: attrs

  # dates can come in various formats through the API
  defp normalize_scheduled_for(attrs = %{ scheduled_for: %DateTime{} }), do: attrs
  defp normalize_scheduled_for(attrs = %{ scheduled_for: scheduled_for }) when is_binary(scheduled_for) do
    {:ok, encoded_scheduled_for} = DateTimeParser.parse(scheduled_for, to_utc: true)
    attrs |> Map.merge(%{scheduled_for: encoded_scheduled_for})
  end
  defp normalize_scheduled_for(attrs), do: attrs

  defp check_methods_with_body(changeset, attrs) do
    if attrs.method in ["get", "delete"] && Map.has_key?(attrs, :body) do
      add_error(changeset, :body, "can't be set using the #{attrs.method} method")
    else
      changeset
    end
  end

  defp check_and_adapt_format_for_headers(changeset, attrs) do
    try do
      Poison.decode!(attrs.headers)
      changeset
    rescue
      Poison.ParseError -> add_error(changeset, :headers, "format isn't valid, it should be a JSON. Please check https://www.notion.so/loschcode/What-s-the-correct-format-to-build-headers-b1507f32ed3f4bd0abfe5ea6f896c9fe for more information.")
    end
  end

  defp check_scheduled_for_in_the_past(changeset, %{ scheduled_for: %DateTime{} }), do: changeset
  defp check_scheduled_for_in_the_past(changeset, attrs = %{ scheduled_for: _ }) do
    {:ok, scheduled_for, _} = attrs.scheduled_for |> DateTime.from_iso8601()

    if scheduled_for |> Timex.before?(Timex.now) do
      add_error(changeset, :scheduled_for, "can't be set in the past")
    else
      changeset
    end
  end
end
