# base schema with all capabilities
# and queries
defmodule Bloodbath.GraphQL.Schema do
  use Absinthe.Schema

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types Bloodbath.GraphQL.Schema.Scalars.Json
  import_types Bloodbath.GraphQL.Schema.Scalars.Uuid
  import_types Bloodbath.GraphQL.Schema.Types

  import_types Bloodbath.GraphQL.Schema.Connect.ChangePasswordFromToken
  import_types Bloodbath.GraphQL.Schema.Connect.ForgotMyPassword
  import_types Bloodbath.GraphQL.Schema.Connect.Signin
  import_types Bloodbath.GraphQL.Schema.Connect.Signup

  import_types Bloodbath.GraphQL.Schema.Public.GetPing
  import_types Bloodbath.GraphQL.Schema.Public.FindEvent
  import_types Bloodbath.GraphQL.Schema.Public.ListEvents
  import_types Bloodbath.GraphQL.Schema.Public.ScheduleEvent
  import_types Bloodbath.GraphQL.Schema.Public.CancelEvent
  import_types Bloodbath.GraphQL.Schema.Dashboard.EditMyAccount

  query do
    import_fields :public_list_events
    import_fields :public_find_event
    import_fields :public_get_ping
  end

  mutation do
    import_fields :connect_signup
    import_fields :connect_signin
    import_fields :connect_change_password_from_token
    import_fields :connect_forgot_my_password
    import_fields :dashboard_edit_my_account
    import_fields :public_schedule_event
    import_fields :public_cancel_event
  end
end

# limited schema for
# the public introspection
defmodule Bloodbath.GraphQL.PublicSchema do
  use Absinthe.Schema

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types Bloodbath.GraphQL.Schema.Scalars.Json
  import_types Bloodbath.GraphQL.Schema.Scalars.Uuid
  import_types Bloodbath.GraphQL.Schema.Types

  import_types Bloodbath.GraphQL.Schema.Public.GetPing
  import_types Bloodbath.GraphQL.Schema.Public.FindEvent
  import_types Bloodbath.GraphQL.Schema.Public.ListEvents
  import_types Bloodbath.GraphQL.Schema.Public.ScheduleEvent
  import_types Bloodbath.GraphQL.Schema.Public.CancelEvent

  query do
    import_fields :public_list_events
    import_fields :public_find_event
    import_fields :public_get_ping
  end

  mutation do
    import_fields :public_schedule_event
    import_fields :public_cancel_event
  end
end
