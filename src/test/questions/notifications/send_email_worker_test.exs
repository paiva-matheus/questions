defmodule Questions.Notifications.SendEmailWorkerTest do
  use Questions.DataCase, async: false
  use Oban.Testing, repo: Questions.Repo

  import Mock

  describe "perform/1" do
    @args %{
      from_name: Faker.Person.name(),
      from_email: Faker.Internet.email(),
      to_name: Faker.Person.name(),
      to_email: Faker.Internet.email(),
      subject: Faker.Lorem.sentence(),
      template_id: "some_template_id",
      data: %{some_field: "some_field_value"}
    }

    test "raise match error" do
      with_mock Questions.Notifications, send_email: fn _ -> {:error, "not sent"} end do
        assert_raise MatchError, fn ->
          perform_job(Questions.Notifications.SendEmailWorker, @args)
        end
      end
    end

    test "send email" do
      assert {:ok, _email_sent} = perform_job(Questions.Notifications.SendEmailWorker, @args)
    end
  end
end
