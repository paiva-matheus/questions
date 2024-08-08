defmodule Questions.StudentsTest do
  use Oban.Testing, repo: Questions.Repo
  use Questions.DataCase, async: false

  alias Questions.Students

  describe "register/1" do
    test "creates student" do
      attrs = %{
        name: Faker.Person.name(),
        email: Faker.Internet.email(),
        password: Faker.String.base64(8)
      }

      assert {:ok, user} = Students.register(attrs)
      assert user.role == "student"
      assert user.name == attrs.name
      assert user.email == attrs.email
      assert Bcrypt.verify_pass(attrs.password, user.encrypted_password)
    end

    test "can register student only once" do
      attrs = %{
        name: Faker.Person.name(),
        email: Faker.Internet.email(),
        password: Faker.String.base64(8)
      }

      {:ok, _user} = Students.register(attrs)
      {:error, changeset} = Students.register(attrs)
      assert errors_on(changeset) == %{email: ["has already been taken"]}
    end

    test "creates a student even when another role is inserted" do
      attrs = %{
        name: Faker.Person.name(),
        email: Faker.Internet.email(),
        password: Faker.String.base64(8),
        role: "admin"
      }

      assert {:ok, user} = Students.register(attrs)
      assert user.role == "student"
    end

    test "validates required fields" do
      assert {:error, changeset} = Students.register(%{})

      assert errors_on(changeset) == %{
               name: ["can't be blank"],
               email: ["can't be blank"],
               password: ["can't be blank"]
             }
    end
  end
end
