defmodule Bloodbath.Schema do
  use Absinthe.Schema

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types Bloodbath.Schema.Scalars.Json
  import_types Bloodbath.Schema.Scalars.Uuid
  import_types Bloodbath.Schema.Types

  import_types Bloodbath.Schema.Connect.ChangePasswordFromToken
  import_types Bloodbath.Schema.Connect.ForgotMyPassword
  import_types Bloodbath.Schema.Connect.Signin
  import_types Bloodbath.Schema.Connect.Signup

  import_types Bloodbath.Schema.Dashboard.GetPing
  import_types Bloodbath.Schema.Dashboard.GetEvent
  import_types Bloodbath.Schema.Dashboard.ListEvents
  import_types Bloodbath.Schema.Dashboard.CreateEvent
  import_types Bloodbath.Schema.Dashboard.RemoveEvent
  import_types Bloodbath.Schema.Dashboard.EditMyAccount

  query do
    import_fields :dashboard_list_events
    import_fields :dashboard_get_event
    import_fields :dashboard_get_ping
  end

  mutation do
    import_fields :connect_signup
    import_fields :connect_signin
    import_fields :connect_change_password_from_token
    import_fields :connect_forgot_my_password
    import_fields :dashboard_create_event
    import_fields :dashboard_remove_event
    import_fields :dashboard_edit_my_account
  end
end
