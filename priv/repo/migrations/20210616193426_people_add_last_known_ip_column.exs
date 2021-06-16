defmodule Bloodbath.Repo.Migrations.PeopleAddLastKnownIpColumn do
  use Ecto.Migration

  def change do
    alter table("people") do
      add :last_known_ip, :string
    end
  end
end
