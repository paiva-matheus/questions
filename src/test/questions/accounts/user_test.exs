defmodule Questions.Accounts.UserTest do
  use Questions.DataCase, async: true

  alias Questions.Accounts.User

  describe "roles/0" do
    test "values validation" do
      expected_roles = [
        "admin",
        "monitor",
        "student"
      ]

      assert User.roles() == expected_roles
    end
  end

  describe "create_changeset/2" do
    test "validates required fields" do
      changeset = User.create_changeset(%User{}, %{})
      refute changeset.valid?

      assert errors_on(changeset) == %{
               email: ["can't be blank"],
               name: ["can't be blank"],
               password: ["can't be blank"],
               role: ["can't be blank"]
             }
    end

    test "validates email format" do
      attrs = %{
        email: "Luke Skywalker",
        role: "monitor",
        name: "Luke Skywalker",
        password: "12345678"
      }

      changeset = User.create_changeset(%User{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset) == %{email: ["has invalid format"]}
    end

    test "validates password min length" do
      attrs = %{
        role: "student",
        name: "Luke Skywalker",
        email: "luke@hotmail.com",
        password: "123456"
      }

      changeset = User.create_changeset(%User{}, attrs)
      refute changeset.valid?
      assert errors_on(changeset) == %{password: ["should be at least 8 character(s)"]}
    end

    test "validates if role is valid" do
      attrs = %{
        name: Faker.Person.name(),
        email: Faker.Internet.email(),
        password: Faker.String.base64(8),
        role: "invalid_role"
      }

      changeset = User.create_changeset(%User{}, attrs)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               role: ["is invalid"]
             }
    end
  end

  describe "update_password_changeset/2" do
    test "validate required" do
      changeset = User.update_password_changeset(%User{}, %{})

      assert errors_on(changeset) == %{
               password: ["can't be blank"],
               password_confirmation: ["can't be blank"]
             }
    end

    test "validate password min length" do
      attrs = %{
        password: "1nvalId",
        password_confirmation: "1nvalId"
      }

      changeset = User.update_password_changeset(%User{}, attrs)
      assert errors_on(changeset) == %{password: ["should be at least 8 character(s)"]}
    end

    test "validate uppercase letter" do
      attrs = %{
        password: "inval1d_password",
        password_confirmation: "inval1d_password"
      }

      changeset = User.update_password_changeset(%User{}, attrs)
      assert errors_on(changeset) == %{password: ["password must contain an uppercase letter"]}
    end

    test "validate number required" do
      attrs = %{
        password: "Invalid_password",
        password_confirmation: "Invalid_password"
      }

      changeset = User.update_password_changeset(%User{}, attrs)
      assert errors_on(changeset) == %{password: ["password must contain a number"]}
    end

    test "validate password confirmation" do
      attrs = %{
        password: "s0me_passWord",
        password_confirmation: "inval1d_passWord"
      }

      changeset = User.update_password_changeset(%User{}, attrs)
      assert errors_on(changeset) == %{password_confirmation: ["does not match confirmation"]}
    end

    test "returns valid changeset" do
      attrs = %{
        password: "s0me_passWord",
        password_confirmation: "s0me_passWord"
      }

      assert changeset = User.update_password_changeset(%User{}, attrs)
      assert changeset.valid?
      assert %{password: password} = changeset.changes
      assert password == "s0me_passWord"
    end
  end

  describe "update_role_changeset/2" do
    test "validate required" do
      changeset = User.update_role_changeset(%User{}, %{})
      assert errors_on(changeset) == %{role: ["can't be blank"]}
    end

    test "validate role inclusion" do
      attrs = %{
        role: "invalid_role"
      }

      changeset = User.update_role_changeset(%User{}, attrs)
      assert errors_on(changeset) == %{role: ["is invalid"]}
    end

    test "returns valid changeset" do
      attrs = %{
        role: "admin"
      }

      changeset = User.update_role_changeset(%User{}, attrs)
      assert changeset.valid?
    end
  end
end
