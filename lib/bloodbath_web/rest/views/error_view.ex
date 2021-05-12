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

  # def translate_errors(changeset) do
  #   Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  # end
  def render_with({message, values}) do
    Enum.reduce values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end
  end

  def render_with(message) do
    message
  end

  def render("error.json", %{changeset: changeset}) do
    errors = Enum.map(changeset.errors, fn {field, detail} ->
      %{
        "#{field}": render_with(detail)
      }
    end)

    %{errors: errors}
  end

  def render("400.json", _assigns) do
    %{errors: ["Bad request"]}
  end

  def render("401.json", _assigns) do
    %{errors: ["Unauthorized"]}
  end

  def render("404.json", _assigns) do
    %{errors: ["Page not found"]}
  end

  def render("500.json", _assigns) do
    %{errors: ["Internal server error"]}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end
end
