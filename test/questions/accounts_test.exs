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

  describe "list_users/1" do
    test "returns a list of user accounts" do
      users =
        [
          Factory.insert(:user, role: "facilitator"),
          Factory.insert(:user, role: "instructor"),
          Factory.insert(:user, role: "admin")
        ]
        |> sort_by_id()

      assert Accounts.list_users([]) == users
    end

    test "returns users filtered by name" do
      user_1 = Factory.insert(:user, %{name: "Jim Halpert"})
      user_2 = Factory.insert(:user, %{name: "Willian Timmot"})
      Factory.insert_list(3, :user)

      assert Accounts.list_users(q: "halper") == [user_1]
      assert Accounts.list_users(q: "tim") == [user_2]
    end

    test "returns users with same first name" do
      user_1 = Factory.insert(:user, %{name: "Willian Timmot"})
      user_2 = Factory.insert(:user, %{name: "Willian Morris"})
      Factory.insert_list(3, :user)

      assert Accounts.list_users(q: "will") == sort_by_id([user_1, user_2])
    end

    test "returns user filtered by email" do
      user_1 = Factory.insert(:user, %{email: "jim@mail.com"})
      Factory.insert_list(3, :user)

      assert Accounts.list_users(q: "jim@mail") == [user_1]
    end

    test "returns users with same name filtered by email" do
      user_1 = Factory.insert(:user, %{email: "john_doe@mail.com"})
      user_2 = Factory.insert(:user, %{email: "johnLee4592@mail.com"})
      Factory.insert_list(3, :user)

      assert Accounts.list_users(q: "JOHN") == sort_by_id([user_1, user_2])
    end

    test "returns users when name and email match with search" do
      user_1 = Factory.insert(:user, %{name: "Ana Carolina"})
      user_2 = Factory.insert(:user, %{name: "Carol Denvers"})
      user_3 = Factory.insert(:user, %{email: "carol@mail.com"})
      Factory.insert_list(3, :user)

      assert Accounts.list_users(q: "carol") == sort_by_id([user_1, user_2, user_3])
    end
  end

  defp sort_by_id(enumerable) do
    Enum.sort(enumerable, fn a, b ->
      a = Map.get(a, :id) || Map.get(a, "id")
      b = Map.get(b, :id) || Map.get(b, "id")
      a >= b
    end)
  end
end
