defmodule Bigseat.Schema do
  use Absinthe.Schema

  import_types Absinthe.Plug.Types
  import_types Absinthe.Type.Custom
  import_types Bigseat.Schema.Scalars.Json
  import_types Bigseat.Schema.Scalars.Uuid
  import_types Bigseat.Schema.Types

  import_types Bigseat.Schema.Connect.ChangePasswordFromToken
  import_types Bigseat.Schema.Connect.ForgotMyPassword
  import_types Bigseat.Schema.Connect.Signin
  import_types Bigseat.Schema.Connect.Signup

  import_types Bigseat.Schema.Dashboard.AddNewTeamMember
  import_types Bigseat.Schema.Dashboard.CreateSpace
  import_types Bigseat.Schema.Dashboard.EditMyAccount
  import_types Bigseat.Schema.Dashboard.EditMyOrganization
  import_types Bigseat.Schema.Dashboard.EditSpace
  import_types Bigseat.Schema.Dashboard.EditPerson
  import_types Bigseat.Schema.Dashboard.GetSpace
  import_types Bigseat.Schema.Dashboard.ListSpaces
  import_types Bigseat.Schema.Dashboard.ListCheckins
  import_types Bigseat.Schema.Dashboard.ListBookings
  import_types Bigseat.Schema.Dashboard.RemovePerson

  import_types Bigseat.Schema.Gateway.BookSpace
  import_types Bigseat.Schema.Gateway.CheckinSpace
  import_types Bigseat.Schema.Gateway.ListSpacesFromBookings

  import_types Bigseat.Schema.Plugins.ImportTeamFromCsv

  query do
    import_fields :dashboard_list_spaces
    import_fields :dashboard_list_checkins
    import_fields :dashboard_list_bookings
    import_fields :dashboard_get_space
    import_fields :gateway_list_spaces_from_bookings
  end

  mutation do
    import_fields :connect_signup
    import_fields :connect_signin
    import_fields :connect_change_password_from_token
    import_fields :dashboard_create_space
    import_fields :dashboard_edit_space
    import_fields :dashboard_edit_person
    import_fields :dashboard_add_new_team_member
    import_fields :dashboard_remove_person
    import_fields :connect_forgot_my_password
    import_fields :dashboard_edit_my_account
    import_fields :dashboard_edit_my_organization
    import_fields :gateway_book_space
    import_fields :gateway_checkin_space
    import_fields :plugins_import_team_from_csv
  end
end
