defmodule Questions.DoubtsTest do
  use Questions.DataCase, async: false

  alias Questions.Doubts
  alias Questions.Doubts.Answer
  alias Questions.Doubts.Question
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

    test "returns question with answers" do
      preload_fields = [:user, answers: [:user]]
      question = Factory.insert(:question)
      Factory.insert_list(10, :answer, question: question)

      expected_question =
        Repo.get(Question, question.id)
        |> Repo.preload(preload_fields)

      assert Doubts.get_question_by_id(question.id, preload_fields) ==
               {:ok, expected_question}
    end
  end

  describe "create_answer/1" do
    test "create a new answer" do
      user = Factory.insert(:user, role: "monitor")
      attrs = Factory.params_with_assocs(:answer, user: user)

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
      user = Factory.insert(:user, role: "monitor")

      attrs = %{
        content: Faker.Lorem.sentence(10),
        user_id: user.id,
        question_id: Ecto.UUID.generate()
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Doubts.create_answer(attrs)
      assert %{question_id: ["does not exist"]} = errors_on(changeset)
    end

    test "returns an error when user doesn't have permission to answer the question" do
      question = Factory.insert(:question)
      user = Factory.insert(:user, role: "student")

      attrs = %{
        content: Faker.Lorem.sentence(10),
        user_id: user.id,
        question_id: question.id
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Doubts.create_answer(attrs)

      assert %{user: ["the user does not have permission to answer the question"]} =
               errors_on(changeset)
    end
  end

  describe "complete_question/2" do
    test "complete question" do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question, status: "open", user: user)

      assert {:ok, completed_question} = Doubts.complete_question(question, user)
      assert completed_question.status == "completed"
    end

    test "returns an error when question is completed" do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question, status: "completed", user: user)
      assert {:error, %Ecto.Changeset{} = changeset} = Doubts.complete_question(question, user)

      assert %{status: ["question is already completed"]} = errors_on(changeset)
    end

    test "returns an error when user does not have permission" do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question, status: "completed")
      assert {:error, :forbidden} = Doubts.complete_question(question, user)
    end
  end

  describe "get_answer_by_id/1" do
    test "returns error when answer doesn't exist" do
      assert Doubts.get_answer_by_id(Ecto.UUID.generate()) == {:error, :not_found}
    end

    test "returns error when id is invalid" do
      assert Doubts.get_answer_by_id("invalid") == {:error, :not_found}
    end

    test "returns answer" do
      preload_fields = [:user]

      answer =
        Factory.insert(:answer)
        |> Repo.reload!()
        |> Repo.preload(preload_fields)

      assert Doubts.get_answer_by_id(answer.id, preload_fields) ==
               {:ok, answer}
    end
  end

  describe "delete_answer/1" do
    test "delete answer" do
      answer = Factory.insert(:answer)

      assert {:ok, deleted_answer} = Doubts.delete_answer(answer)
      refute Repo.get(Answer, deleted_answer.id)
    end
  end

  describe "favorite_answer/1" do
    test "favorite answer" do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question, user: user)
      answer = Factory.insert(:answer, question: question)

      assert {:ok, favorited_answer} = Doubts.favorite_answer(answer)
      assert favorited_answer.favorite == true
    end

    test "returns an error when answer is already favorited" do
      answer = Factory.insert(:answer, favorite: true)
      assert {:error, %Ecto.Changeset{} = changeset} = Doubts.favorite_answer(answer)

      assert %{answer: ["There is already a favorited answer for this question"]} =
               errors_on(changeset)
    end
  end

  describe "unfavorite_answer/1" do
    test "unfavorite answer" do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question, user: user)
      answer = Factory.insert(:answer, question: question, favorite: true)

      assert {:ok, unfavorited_answer} = Doubts.unfavorite_answer(answer)
      assert unfavorited_answer.favorite == false
    end

    test "returns an error when answer is already favorited" do
      answer = Factory.insert(:answer)
      assert {:error, %Ecto.Changeset{} = changeset} = Doubts.unfavorite_answer(answer)

      assert %{answer: ["The answer is not favorited"]} =
               errors_on(changeset)
    end
  end

  describe "question_belong_to_requesting_user?/2" do
    test "returns true when question belong to user" do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question, user: user)

      assert Doubts.question_belong_to_requesting_user?(question, user)
    end

    test "returns false when question not belong to user" do
      user = Factory.insert(:user, role: "student")
      question = Factory.insert(:question)

      refute Doubts.question_belong_to_requesting_user?(question, user)
    end
  end
end
