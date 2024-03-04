defmodule Questions.Notifications.SendEmailWorker do
  @moduledoc false
  use Oban.Worker, queue: :notifications

  alias Questions.Notifications
  alias Questions.Notifications.Email

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    attrs = %Email{
      from_name: args["from_name"],
      from_email: args["from_email"],
      to_name: args["to_name"],
      to_email: args["to_email"],
      subject: args["subject"],
      template_id: args["template_id"],
      data: args["data"]
    }

    {:ok, _email_sent} = Notifications.send_email(attrs)
  end
end
