defmodule Bloodbath.Schema.Dashboard.RemoveEvent do
  import Ecto.Query, warn: false
  use Absinthe.Schema.Notation
  alias Bloodbath.Repo
  alias Crudry.Middlewares.TranslateErrors
  alias Bloodbath.Core.Event

  object :dashboard_remove_event do
    @desc "Remove an event from the organization"
    field :remove_event, :dashboard_event do
      arg :id, non_null(:uuid)

      middleware BloodbathWeb.Middleware.AuthorizedAdmin
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, %{ id: id }, %{ context: %{ myself: %{ organization_id: organization_id } }}) do
    event = Event |> where(id: ^id) |> where(organization_id: ^organization_id) |> Repo.one()
    case event do
      %Event{} -> Bloodbath.Core.Events.delete(event)
      _ -> {:error, "event not found"}
    end
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
