defmodule BloodbathWeb.ErrorView do
  use BloodbathWeb, :view

  def render("error.json", %{changeset: changeset}) do
    %{errors: changeset}
  end

  def render("400.json", _assigns) do
    %{errors: "Bad request"}
  end

  def render("404.json", _assigns) do
    %{errors: "Page not found"}
  end

  def render("500.json", _assigns) do
    %{errors: "Internal server error"}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.json", assigns
  end
end