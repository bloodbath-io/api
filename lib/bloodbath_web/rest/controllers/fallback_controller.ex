defmodule BloodbathWeb.FallbackController do
  use BloodbathWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BloodbathWeb.ErrorView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(BloodbathWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, error}) do
    conn
    |> put_status(:not_found)
    |> put_view(BloodbathWeb.ErrorView)
    |> render("error.json", error: error)
  end
end
