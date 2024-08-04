defmodule Questions.Doubts.AnswerTest do
  use Questions.DataCase, async: true

  alias Questions.Doubts.Answer
  alias Questions.Factory

  describe "create_changeset/2" do
    test "returns valid changeset" do
      attrs = Factory.params_with_assocs(:answer)
      changeset = Answer.create_changeset(%Answer{}, attrs)

      assert changeset.valid?

      assert changeset.changes == %{
               content: attrs.content,
               question_id: attrs.question_id,
               user_id: attrs.user_id
             }
    end

    test "validates required fields" do
      changeset = Answer.create_changeset(%Answer{}, %{})
      refute changeset.valid?

      assert errors_on(changeset) == %{
               question_id: ["can't be blank"],
               user_id: ["can't be blank"],
               content: ["can't be blank"]
             }
    end

    test "validate role" do
      user = Factory.insert(:user, role: "student")
      attrs = Factory.params_with_assocs(:answer, user: user)
      changeset = Answer.create_changeset(%Answer{}, attrs)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               user: ["the user does not have permission to answer the question"]
             }
    end
  end

  describe "favorite_changeset/1" do
    test "returns valid changeset" do
      answer = Factory.insert(:answer)
      changeset = Answer.favorite_changeset(answer)

      assert changeset.valid?

      assert changeset.changes == %{
               favorite: true
             }
    end

    test "validates if the answer can be favorited" do
      question = Factory.insert(:question)
      Factory.insert(:answer, question: question, favorite: true)
      answer = Factory.insert(:answer, question: question)
      changeset = Answer.favorite_changeset(answer)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               answer: ["There is already a favorited answer for this question"]
             }
    end
  end
end
