defmodule Questions.Doubts.ThreadTest do
  use Questions.DataCase, async: true

  alias Questions.Doubts.Thread

  describe "create_changeset/2" do
    test "returns valid changeset" do
      attrs = %{question_id: Faker.UUID.v4()}
      changeset = Thread.create_changeset(%Thread{}, attrs)

      assert changeset.valid?
      assert changeset.changes == %{question_id: attrs.question_id}
    end

    test "validates required fields" do
      changeset = Thread.create_changeset(%Thread{}, %{})
      refute changeset.valid?

      assert errors_on(changeset) == %{question_id: ["can't be blank"]}
    end
  end
end
