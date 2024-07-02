defmodule Questions.AccountsTest do
  use Oban.Testing, repo: Questions.Repo
  use Questions.DataCase, async: false

  alias Questions.Accounts
  alias Questions.Factory

  describe "get_user/1" do
    test "returns error when id is not a valid uuid" do
      assert {:error, :not_found} == Accounts.get_user("invalid_id")
    end

    test "returns error when user does not exist" do
      assert {:error, :not_found} == Accounts.get_user(Ecto.UUID.generate())
    end

    test "returns the user" do
      user = Factory.insert(:user)

      assert {:ok, user} == Accounts.get_user(user.id)
    end
  end

  describe "register/1" do
    test "creates user" do
      attrs = %{
        name: Faker.Person.name(),
        email: Faker.Internet.email(),
        password: Faker.String.base64(8),
        role: "student"
      }

      assert {:ok, %{user: user}} = Accounts.register(attrs)
      assert user.role == "student"
      assert user.name == attrs.name
      assert user.email == attrs.email
      assert Bcrypt.verify_pass(attrs.password, user.encrypted_password)
    end

    test "can register user only once" do
      attrs = %{
        name: Faker.Person.name(),
        email: Faker.Internet.email(),
        password: Faker.String.base64(8),
        role: "student"
      }

      {:ok, _user} = Accounts.register(attrs)
      {:error, changeset} = Accounts.register(attrs)
      assert errors_on(changeset) == %{email: ["has already been taken"]}
    end

    test "validates if role is valid" do
      attrs = %{
        name: Faker.Person.name(),
        email: Faker.Internet.email(),
        password: Faker.String.base64(8),
        role: "invalid_role"
      }

      assert {:error, changeset} = Accounts.register(attrs)

      assert errors_on(changeset) == %{
               role: ["is invalid"]
             }
    end

    test "validates required fields" do
      assert {:error, changeset} = Accounts.register(%{})

      assert errors_on(changeset) == %{
               name: ["can't be blank"],
               email: ["can't be blank"],
               password: ["can't be blank"],
               role: ["can't be blank"]
             }
    end
  end

  describe "sign_in/1" do
    test "returns authenticated token and claims" do
      user = Factory.insert(:user)

      attrs = %{
        email: user.email,
        password: "12345678"
      }

      assert {:ok, jwt, claims} = Accounts.sign_in(attrs)

      assert {:ok, claims} ==
               Guardian.decode_and_verify(Questions.AccessControl.Guardian, jwt, claims)
    end

    test "validates required fields" do
      assert {:error, changeset} = Accounts.sign_in(%{})

      assert errors_on(changeset) == %{
               email: ["can't be blank"],
               password: ["can't be blank"]
             }
    end

    test "returns not found when user does not exist" do
      assert {:error, :not_found} =
               Accounts.sign_in(%{email: Faker.Internet.email(), password: "123"})
    end
  end
end
