defmodule Questions.DoubtsTest do
  use Questions.DataCase, async: false

  alias Questions.Doubts
  alias Questions.Factory

  describe "create_question/1" do
    test "create a new question" do
      attrs = Factory.params_with_assocs(:question)

      assert {:ok, created_question} = Doubts.create_question(attrs)
      assert created_question.title == attrs.title
      assert created_question.description == attrs.description
      assert created_question.status == "open"
      assert created_question.category == attrs.category
    end

    test "returns an error when required fields are missing" do
      assert {:error, %Ecto.Changeset{} = changeset} = Doubts.create_question(%{})

      assert %{
               title: ["can't be blank"],
               description: ["can't be blank"],
               user_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns an error when user_id doesn't exist" do
      attrs = Factory.params_for(:question, user_id: Ecto.UUID.generate())

      assert {:error, %Ecto.Changeset{} = changeset} = Doubts.create_question(attrs)
      assert %{user_id: ["does not exist"]} = errors_on(changeset)
    end
  end
end
