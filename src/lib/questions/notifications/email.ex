defmodule Questions.Notifications.Email do
  @moduledoc false
  @enforce_keys ~w(from_name to_name from_email to_email subject template_id)a
  defstruct ~w(from_name to_name from_email to_email subject template_id data)a
end
