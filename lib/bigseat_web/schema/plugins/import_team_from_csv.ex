defmodule Bigseat.Schema.Plugins.ImportTeamFromCsv do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :plugins_import_team_from_csv do
    @desc "Import team members from CSV"
    field :import_team_from_csv, list_of(:gateway_person) do
      arg :file, non_null(:upload)

      # middleware BigseatWeb.Middleware.AuthorizedAdmin
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, %{ file: file }, _resolution) do
    with {:ok, path} <- csv?(file.path),
         {:ok, people} <- csv_to_people(path) do
          # TODO : insertion here
          # %Booking{}
          # |> Booking.create_changeset(params)
          # |> Ecto.Changeset.put_assoc(:space, space)
          # |> Ecto.Changeset.put_assoc(:person, person)
          # |> Repo.insert()
    end
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end

  defp csv_to_people(path) do
    stream = path
    |> Path.expand(__DIR__)
    |> File.stream!
    |> CSV.decode

    header = stream |> Enum.take(1)
    serialized = stream |> Enum.map(&csv_line_to_person(&1, header)) |> Enum.filter(& !is_nil(&1))

    {:ok, serialized}
  end

  defp csv_line_to_person({:ok, line}, [ok: header]) do
    if line != header do
      resource = [header, line]

      %{
        email: resource |> find_value_of("email"),
        first_name: resource |> find_value_of("first_name"),
        last_name: resource |> find_value_of("last_name")
      }
    end
  end

  defp find_value_of([header, line], label) do
    index = header |> Enum.find_index(fn(key) -> key == label end)
    line |> Enum.at(index)
  end

  defp csv?(path) do
    %{ ^path => mime } = FileInfo.get_info(path)
    case mime do
    %FileInfo.Mime{ type: "text", subtype: "plain" } -> {:ok, path}
    _ -> {:error, "not a csv file"}
    end
  end
end
