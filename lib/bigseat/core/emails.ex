defmodule Bigseat.Core.Emails do
  import Bamboo.Email

  def request_new_password(email, token) do
    new_email(
      to: email,
      from: "support@bigseat.co",
      subject: "Reset your password.",
      text_body: "Here is your token #{token}"
    )
  end
end
