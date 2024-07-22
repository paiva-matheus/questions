defmodule Questions.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Questions.Repo

  alias Questions.Accounts.User

  def user_factory do
    %User{
      name: sequence("some_user"),
      token: nil,
      email: sequence(:email, &"user#{&1}@example.com"),
      encrypted_password: Bcrypt.hash_pwd_salt("12345678"),
      role: sequence(:role, ["admin", "student", "monitor"])
    }
  end
end
