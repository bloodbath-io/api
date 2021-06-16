defmodule Bloodbath.TrackingHandler.Services.Mixpanel do
  @project_token "aadf0c8ebbf11c7998c25be10841eadb"
  @headers [
    {"Content-Type", "application/x-www-form-urlencoded"},
    {"Accept", "text/plain"}
  ]

  def track_event(distinct_id, event, _other_data \\ %{}) do
    "https://api.mixpanel.com/track#live-event"
    |> dispatch_payload(%{
      event: event,
      properties: %{
        distinct_id: distinct_id,
        token: @project_token
      }
    })
  end

  def create_identity(distinct_id) do
    "https://api.mixpanel.com/track#create-identity"
    |> dispatch_payload(%{
      event: "$identify",
      properties: %{
        "$identified_id": distinct_id,
        "$anon_id": distinct_id,
        token: @project_token
      }
    })
  end

  def set_profile(distinct_id, ip, dataset \\ %{}) do
    "https://api.mixpanel.com/engage#profile-set"
    |> dispatch_payload(%{
      "$distinct_id": distinct_id,
      "$ip": ip,
      "$set": dataset,
      "$token": @project_token
    })
  end

  defp dispatch_payload(endpoint, payload) do
    data = payload |> Poison.encode!
    encoded_data = %{
      data: data,
      verbose: "1" # to have all details output if there's an error
    } |> URI.encode_query()

    HTTPoison.post(
      endpoint,
      encoded_data,
      @headers
    )
  end
end
