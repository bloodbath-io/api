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

  import_types Bloodbath.Schema.Public.GetPing
  import_types Bloodbath.Schema.Public.GetEvent
  import_types Bloodbath.Schema.Public.ListEvents
  import_types Bloodbath.Schema.Public.CreateEvent
  import_types Bloodbath.Schema.Public.RemoveEvent
  import_types Bloodbath.Schema.Public.EditMyAccount

  query do
    import_fields :public_list_events
    import_fields :public_get_event
    import_fields :public_get_ping
  end

  mutation do
    import_fields :connect_signup
    import_fields :connect_signin
    import_fields :connect_change_password_from_token
    import_fields :connect_forgot_my_password
    import_fields :public_create_event
    import_fields :public_remove_event
    import_fields :public_edit_my_account
  end
end
