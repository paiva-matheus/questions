defmodule Questions.Doubts.QuestionTest do
  use Questions.DataCase, async: true

  alias Questions.Doubts.Question
  alias Questions.Factory

  describe "create_changeset/2" do
    test "returns valid changeset" do
      attrs = %{
        title: Faker.String.base64(8),
        description: Faker.String.base64(8),
        category: "technology",
        user_id: Faker.UUID.v4()
      }

      changeset = Question.create_changeset(%Question{}, attrs)

      assert changeset.valid?

      assert changeset.changes == %{
               title: attrs.title,
               description: attrs.description,
               category: attrs.category,
               user_id: attrs.user_id,
               status: "open"
             }
    end

    test "validates required fields" do
      changeset = Question.create_changeset(%Question{}, %{})
      refute changeset.valid?

      assert errors_on(changeset) == %{
               title: ["can't be blank"],
               description: ["can't be blank"],
               category: ["can't be blank"],
               user_id: ["can't be blank"]
             }
    end

    test "validates if category is valid" do
      attrs = %{
        title: Faker.String.base64(8),
        description: Faker.String.base64(8),
        user_id: Faker.UUID.v4(),
        category: "invalid_category"
      }

      changeset = Question.create_changeset(%Question{}, attrs)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               category: ["is invalid"]
             }
    end
  end

  describe "complete_changeset/2" do
    test "returns valid changeset" do
      question = Factory.insert(:question, status: "open")
      changeset = Question.complete_changeset(question)

      assert changeset.valid?
      assert changeset.changes == %{status: "completed"}
    end

    test "returns an error when question is already completed" do
      question = Factory.insert(:question, status: "completed")
      changeset = Question.complete_changeset(question)

      refute changeset.valid?
      assert errors_on(changeset) == %{status: ["question is already completed"]}
    end
  end

  describe "start_changeset/2" do
    test "returns valid changeset" do
      question = Factory.insert(:question, status: "open")
      changeset = Question.start_changeset(question)

      assert changeset.valid?
      assert changeset.changes == %{status: "in_progress"}
    end

    test "returns an error when question is already in progress" do
      question = Factory.insert(:question, status: "in_progress")
      changeset = Question.start_changeset(question)

      refute changeset.valid?
      assert errors_on(changeset) == %{status: ["question is already in progress"]}
    end

    test "returns an error when question is completed" do
      question = Factory.insert(:question, status: "completed")
      changeset = Question.start_changeset(question)

      refute changeset.valid?
      assert errors_on(changeset) == %{status: ["question is completed"]}
    end
  end
end
