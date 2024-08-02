defmodule Questions.AccessControlTest do
  use Questions.DataCase, async: true

  alias Questions.AccessControl
  alias Questions.Factory

  describe "authorize/2" do
    test "admins can assign roles" do
      user = Factory.build(:user, role: "admin")
      assert :ok = AccessControl.authorize(user, :assign_role)
    end

    test "admins can create users" do
      user = Factory.build(:user, role: "admin")
      assert :ok = AccessControl.authorize(user, :create_user)
    end

    test "the roles that can list user accounts" do
      roles = ["admin", "monitor"]

      for role <- roles do
        user = Factory.build(:user, role: role)
        assert :ok = AccessControl.authorize(user, :list_users)
      end
    end

    test "the roles that can create questions" do
      roles = ["admin", "monitor", "student"]

      for role <- roles do
        user = Factory.build(:user, role: role)
        assert :ok = AccessControl.authorize(user, :create_question)
      end
    end
  end
end
