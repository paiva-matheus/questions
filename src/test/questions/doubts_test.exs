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

  describe "get_question_by_id/1" do
    test "returns error when question doesn't exist" do
      assert Doubts.get_question_by_id(Ecto.UUID.generate()) == {:error, :not_found}
    end

    test "returns error when id is invalid" do
      assert Doubts.get_question_by_id("invalid") == {:error, :not_found}
    end

    test "returns question" do
      preload_fields = [:user]

      question =
        Factory.insert(:question)
        |> Repo.reload!()
        |> Repo.preload(preload_fields)

      assert Doubts.get_question_by_id(question.id, preload_fields) ==
               {:ok, question}
    end
  end

  describe "create_answer/1" do
    test "create a new answer" do
      attrs = Factory.params_with_assocs(:answer)

      assert {:ok, created_answer} = Doubts.create_answer(attrs)
      assert created_answer.content == attrs.content
      assert created_answer.user_id == attrs.user_id
      assert created_answer.question_id == attrs.question_id
    end

    test "returns an error when required fields are missing" do
      assert {:error, %Ecto.Changeset{} = changeset} = Doubts.create_answer(%{})

      assert %{
               content: ["can't be blank"],
               question_id: ["can't be blank"],
               user_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns an error when user_id doesn't exist" do
      question = Factory.insert(:question)

      attrs = %{
        content: Faker.Lorem.sentence(10),
        user_id: Ecto.UUID.generate(),
        question_id: question.id
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Doubts.create_answer(attrs)
      assert %{user_id: ["does not exist"]} = errors_on(changeset)
    end

    test "returns an error when question_id doesn't exist" do
      user = Factory.insert(:user)

      attrs = %{
        content: Faker.Lorem.sentence(10),
        user_id: user.id,
        question_id: Ecto.UUID.generate()
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Doubts.create_answer(attrs)
      assert %{question_id: ["does not exist"]} = errors_on(changeset)
    end
  end
end
