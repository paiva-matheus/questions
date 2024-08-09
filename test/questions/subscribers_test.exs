defmodule Questions.QuestionSubscriberTest do
  use Questions.DataCase, async: false

  alias Questions.Subscribers
  alias Questions.Doubts.QuestionSubscriber
  alias Questions.Factory

  describe "create_question_subscriber/1" do
    test "create a new question" do
      user = Factory.insert(:user, role: "monitor")
      attrs = Factory.params_with_assocs(:question_subscriber, user: user)

      assert {:ok, %QuestionSubscriber{} = created_question_subscriber} =
               Subscribers.create_question_subscriber(attrs)

      assert created_question_subscriber.user_id == attrs.user_id
      assert created_question_subscriber.category == attrs.category
    end

    test "returns an error when required fields are missing" do
      assert {:error, %Ecto.Changeset{} = changeset} = Subscribers.create_question_subscriber(%{})

      assert %{
               category: ["can't be blank"],
               user_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns an error when user_id doesn't exist" do
      attrs = %{
        user_id: Ecto.UUID.generate(),
        category: "technology"
      }

      assert {:error, %Ecto.Changeset{} = changeset} =
               Subscribers.create_question_subscriber(attrs)

      assert %{user_id: ["does not exist"]} = errors_on(changeset)
    end

    test "returns an error when the user is not a monitor" do
      user = Factory.insert(:user, role: "student")
      attrs = Factory.params_with_assocs(:question_subscriber, user: user)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Subscribers.create_question_subscriber(attrs)

      assert %{user: ["Only users with the monitor role can subscriber question"]} =
               errors_on(changeset)
    end
  end
end
