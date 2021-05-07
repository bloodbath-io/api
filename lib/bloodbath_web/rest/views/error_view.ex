defmodule BloodbathWeb.ErrorView do
  use BloodbathWeb, :view

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: changeset}) do
    %{errors: translate_errors(changeset)}
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
