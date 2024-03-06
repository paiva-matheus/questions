defmodule Questions.Notifications do
  @moduledoc false
  import Swoosh.Email

  alias Questions.Notifications.Email

  def send_email(%Email{} = attrs) do
    new()
    |> from({attrs.from_name, attrs.from_email})
    |> to({attrs.to_name, attrs.to_email})
    |> subject(attrs.subject)
    |> put_provider_option(:dynamic_template_data, attrs.data)
    |> put_provider_option(:template_id, attrs.template_id)
    |> Questions.Mailer.deliver()
  end
end
