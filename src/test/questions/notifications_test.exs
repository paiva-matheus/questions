defmodule Questions.NotificationsTest do
  use ExUnit.Case, async: false

  import Mock
  import Swoosh.TestAssertions

  alias Questions.Mailer
  alias Questions.Notifications
  alias Questions.Notifications.Email

  describe "send_email/1" do
    @attrs %Email{
      from_name: Faker.Person.name(),
      from_email: Faker.Internet.email(),
      to_name: Faker.Person.name(),
      to_email: Faker.Internet.email(),
      subject: Faker.Lorem.sentence(),
      template_id: "some_template_id",
      data: %{some_field: "some_field_value"}
    }

    test "returns error when wasn't sent" do
      with_mock Mailer, deliver: fn _ -> {:error, "not sent"} end do
        assert {:error, "not sent"} = Notifications.send_email(@attrs)
        refute_email_sent()
      end
    end

    test "returns ok" do
      assert {:ok, %{}} = Notifications.send_email(@attrs)
      assert_email_sent(to: {@attrs.to_name, @attrs.to_email})
    end
  end
end
