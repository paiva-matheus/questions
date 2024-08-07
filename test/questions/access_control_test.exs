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

    test "the roles that can get questions" do
      roles = ["admin", "monitor", "student"]

      for role <- roles do
        user = Factory.build(:user, role: role)
        assert :ok = AccessControl.authorize(user, :get_question)
      end
    end

    test "the roles that can create answer" do
      roles = ["admin", "monitor"]

      for role <- roles do
        user = Factory.build(:user, role: role)
        assert :ok = AccessControl.authorize(user, :create_answer)
      end
    end

    test "the roles that can complete question" do
      roles = ["admin", "student"]

      for role <- roles do
        user = Factory.build(:user, role: role)
        assert :ok = AccessControl.authorize(user, :complete_question)
      end
    end

    test "the roles that can delete answer" do
      roles = ["admin", "monitor"]

      for role <- roles do
        user = Factory.build(:user, role: role)
        assert :ok = AccessControl.authorize(user, :delete_answer)
      end
    end

    test "students can favorite answer" do
      user = Factory.build(:user, role: "student")
      assert :ok = AccessControl.authorize(user, :favorite_answer)
    end

    test "students can unfavorite answer" do
      user = Factory.build(:user, role: "student")
      assert :ok = AccessControl.authorize(user, :unfavorite_answer)
    end

    test "the roles that can delete question" do
      roles = ["admin", "student"]

      for role <- roles do
        user = Factory.build(:user, role: role)
        assert :ok = AccessControl.authorize(user, :delete_question)
      end
    end
  end
end
