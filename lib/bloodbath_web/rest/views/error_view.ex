# this is a hack for Jason to accept tuples as errors
# basically changeset.errors directly put into the view
# defmodule TupleEncoder do
#   alias Jason.Encoder

#   defimpl Encoder, for: Tuple do
#     def encode(data, options) when is_tuple(data) do
#       data
#       |> Tuple.to_list()
#       |> Encoder.List.encode(options)
#     end
#   end
# end

defmodule BloodbathWeb.ErrorView do
  use BloodbathWeb, :view

  def render("error.json", %{error: error}) do
    %{errors: [error]}
  end

  def render("error.json", %{changeset: changeset}) do
    errors = Enum.map(changeset.errors, fn {field, detail} ->
      %{
        "#{field}": render_with(detail)
      }
    end)

    %{errors: errors}
  end

  def render("400.json", %{ conn: %Plug.Conn{ assigns: %{ reason: %Plug.Parsers.ParseError{} }}}) do
    %{errors: ["Format error. It seems your request body or/and headers were malformatted while sending it to Bloodbath API. Your payload must be written in JSON. Please read https://bloodbath.notion.site/Wrong-format-when-sending-my-body-over-the-REST-API-a3ec73c19f944f2d9ea91a2b7222a149 for more information."]}
  end

  def render("400.json", _assigns) do
    %{errors: ["Bad request"]}
  end

  def render("401.json", _assigns) do
    %{errors: ["Unauthorized"]}
  end

  def render("404.json", _assigns) do
    %{errors: ["Not found"]}
  end

  def render("500.json", _assigns) do
    %{errors: ["Internal server error"]}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end

  defp render_with({message, values}) do
    Enum.reduce values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end
  end

  defp render_with(message) do
    message
  end
end
