defmodule Bloodbath.CustomerEventsManagement.Event do
  import Ecto.Changeset
  import Ecto.Query, warn: false
  use Ecto.Schema
  alias Bloodbath.Repo

  alias Bloodbath.CustomerEventsManagement.{
    Event,
  }

  @events_hard_limit 5_000

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

  def create_changeset(event, attrs, context = %{ organization_id: organization_id }) do
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
      |> check_body_size(normalized_attributes)
      |> check_headers_size(normalized_attributes)
      # limit rates validations
      |> check_scheduled_events_limit(organization_id)
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
      Poison.ParseError -> add_error(changeset, :headers, "format isn't valid, it should be a JSON. Please check https://docs.bloodbath.io/loschcode/What-s-the-correct-format-to-build-headers-b1507f32ed3f4bd0abfe5ea6f896c9fe for more information.")
    end
  end

  # 50KB is the hard limit on most HTTP servers
  def check_headers_size(changeset, attrs) do
    if byte_size(attrs.headers) > 50_000 do
      add_error(changeset, :headers, "can't be more than 50KB. Please check https://docs.bloodbath.io/loschcode/What-are-the-maximum-body-and-headers-size-803289e02fd848b29121665ec7208d5d for more information.")
    else
      changeset
    end
  end

  # 1MB is large enough for any body texts
  # if customers need more we can arrange some system through S3
  def check_body_size(changeset, attrs) do
    if byte_size(attrs.body) > 1_000_000 do
      add_error(changeset, :body, "can't be more than 1MB. Please check https://docs.bloodbath.io/loschcode/What-are-the-maximum-body-and-headers-size-803289e02fd848b29121665ec7208d5d for more information.")
    else
      changeset
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

  defp check_scheduled_events_limit(changeset, organization_id) do
    if scheduled_events_for(organization_id) > @events_hard_limit do
      add_error(changeset, :scheduled_for, "too many events were already created for your account. Please contact our support.")
    else
      changeset
    end
  end

  def scheduled_events_for(organization_id) do
    query = from event in Event,
    where: event.organization_id == ^organization_id
    # where: event.scheduled_for >= ^Timex.now -> we don't base on time anymore

    query |> Repo.aggregate(:count, :id)
  end
end
