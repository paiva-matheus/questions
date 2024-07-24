defmodule Questions.Doubts.AnswerTest do
  use Questions.DataCase, async: true

  alias Questions.Doubts.Answer

  describe "create_changeset/2" do
    test "returns valid changeset" do
      attrs = %{content: Faker.Lorem.sentence(), thread_id: Faker.UUID.v4()}
      changeset = Answer.create_changeset(%Answer{}, attrs)

      assert changeset.valid?
      assert changeset.changes == %{thread_id: attrs.thread_id, content: attrs.content}
    end

    test "validates required fields" do
      changeset = Answer.create_changeset(%Answer{}, %{})
      refute changeset.valid?

      assert errors_on(changeset) == %{thread_id: ["can't be blank"], content: ["can't be blank"]}
    end
  end
end
