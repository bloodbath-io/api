defmodule BloodbathWeb.ChangesetView do
  use BloodbathWeb, :view

  def render("error.json", %{changeset: changeset}) do
    %{errors: changeset}
  end
end
