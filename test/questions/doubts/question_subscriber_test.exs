defmodule Questions.Doubts.QuestionSubscriberTest do
  use Questions.DataCase, async: true

  alias Questions.Doubts.QuestionSubscriber
  alias Questions.Factory

  describe "create_changeset/2" do
    test "returns valid changeset" do
      user = Factory.insert(:user, role: "monitor")

      attrs = %{
        category: "technology",
        user_id: user.id
      }

      changeset = QuestionSubscriber.create_changeset(%QuestionSubscriber{}, attrs)

      assert changeset.valid?

      assert changeset.changes == %{
               category: attrs.category,
               user_id: attrs.user_id
             }
    end

    test "validates required fields" do
      changeset = QuestionSubscriber.create_changeset(%QuestionSubscriber{}, %{})
      refute changeset.valid?

      assert errors_on(changeset) == %{
               category: ["can't be blank"],
               user_id: ["can't be blank"]
             }
    end

    test "validates if category is valid" do
      user = Factory.insert(:user, role: "monitor")

      attrs = %{
        user_id: user.id,
        category: "invalid_category"
      }

      changeset = QuestionSubscriber.create_changeset(%QuestionSubscriber{}, attrs)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               category: ["is invalid"]
             }
    end

    test "validates if user exist" do
      attrs = %{
        user_id: Ecto.UUID.generate(),
        category: "technology"
      }

      changeset = QuestionSubscriber.create_changeset(%QuestionSubscriber{}, attrs)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               user_id: ["does not exist"]
             }
    end

    test "validates if user is monitor" do
      user = Factory.insert(:user, role: "student")

      attrs = %{
        user_id: user.id,
        category: "technology"
      }

      changeset = QuestionSubscriber.create_changeset(%QuestionSubscriber{}, attrs)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               user: ["Only users with the monitor role can subscriber question"]
             }
    end
  end
end
