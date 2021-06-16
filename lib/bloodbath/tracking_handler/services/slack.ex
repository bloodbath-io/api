defmodule Bloodbath.TrackingHandler.Services.Slack do
  @hook_url "https://hooks.slack.com/services/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"
  @headers [
    {"Content-Type", "application/json"},
  ]

  def send_message(message) do
    dispatch_payload(%{
      text: message
    })
  end

  defp dispatch_payload(payload) do
    data = payload |> Poison.encode!

    HTTPoison.post(
      @hook_url,
      data,
      @headers
    )
  end
end
