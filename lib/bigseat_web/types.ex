defmodule Bigseat.Schema.Types do
  use Absinthe.Schema.Notation

  object :connect_person do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string
    field :api_key, :string
    field :organization, :dashboard_organization
    field :password_recovery_token, :string
  end

  object :dashboard_person do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :organization, :dashboard_organization
  end

  object :gateway_person do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :email, :string
  end

  object :gateway_space do
    field :id, :uuid
    field :avatar, :string
    field :name, :string
    field :slug, :string
    field :maximum_people, :integer
    field :open_hours, list_of(:dashboard_space_open_hour)
    field :bookings, list_of(:gateway_booking)
  end

  object :gateway_booking do
    field :id, :uuid
    field :start_at, :datetime
    field :end_at, :datetime
    field :person, :gateway_person
    field :space, :gateway_space
  end

  object :dashboard_booking do
    field :id, :uuid
    field :start_at, :datetime
    field :end_at, :datetime
    field :person, :dashboard_person
    field :space, :dashboard_space
  end

  object :gateway_checkin do
    field :id, :uuid
    field :checked_at, :datetime
    field :end_at, :datetime
    field :person, :gateway_person
    field :space, :gateway_space
  end

  object :dashboard_checkin do
    field :id, :uuid
    field :checked_at, :datetime
    field :end_at, :datetime
    field :person, :dashboard_person
    field :space, :dashboard_space
  end

  object :dashboard_space do
    field :id, :uuid
    field :avatar, :string
    field :name, :string
    field :slug, :string
    field :maximum_people, :integer
    field :open_hours, list_of(:dashboard_space_open_hour)
    field :organization, :dashboard_organization
  end

  object :dashboard_space_open_hour do
    field :id, :uuid
    field :space_id, :id
    field :day_of_the_week, :string
    field :open_time, :time
    field :close_time, :time
  end

  object :dashboard_organization do
    field :id, :uuid
    field :name, :string
    field :slug, :string
  end
end
