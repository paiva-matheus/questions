defmodule Questions.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Questions.Repo

  alias Questions.Accounts.User
  alias Questions.Question

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
      user_id: Faker.UUID.v4()
    }
  end
end
