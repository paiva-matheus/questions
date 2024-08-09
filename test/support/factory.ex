defmodule Questions.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Questions.Repo

  alias Questions.Accounts.User
  alias Questions.Doubts.Answer
  alias Questions.Doubts.Question
  alias Questions.Doubts.QuestionSubscriber

  def user_factory do
    %User{
      name: sequence("some_user"),
      token: nil,
      email: sequence(:email, &"user#{&1}@example.com"),
      encrypted_password: Bcrypt.hash_pwd_salt("12345678"),
      role: sequence(:role, ["admin", "student", "monitor"])
    }
  end

  def question_factory do
    %Question{
      title: sequence("some_title"),
      description: sequence("some_description"),
      category: sequence(:category, ["technology", "engineering", "science", "others"]),
      status: sequence(:status, ["open", "in_progress", "completed"]),
      user: build(:user)
    }
  end

  def answer_factory do
    %Answer{
      content: Faker.Lorem.sentence(10),
      question: build(:question),
      user: build(:user, role: "monitor"),
      favorite: false
    }
  end

  def question_subscriber_factory do
    %QuestionSubscriber{
      category: sequence(:category, ["technology", "engineering", "science", "others"]),
      user: build(:user)
    }
  end
end
