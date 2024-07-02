defmodule Questions.AccessControl.GuardianTest do
  use Questions.DataCase
  alias Questions.AccessControl.Guardian
  alias Questions.Accounts.User
  alias Questions.Factory

  describe "subject_for_token/2" do
    test "returns user_id" do
      user = %User{id: "0b1eb4a0-9fed-4276-a37e-3c616c7cf27a"}

      assert Guardian.subject_for_token(user, %{}) ==
               {:ok, "0b1eb4a0-9fed-4276-a37e-3c616c7cf27a"}
    end
  end

  describe "resource_from_claims/1" do
    test "returns user" do
      user = Factory.insert(:user, id: "0b1eb4a0-9fed-4276-a37e-3c616c7cf27a")

      assert {:ok, user} ==
               Guardian.resource_from_claims(%{
                 "sub" => "0b1eb4a0-9fed-4276-a37e-3c616c7cf27a"
               })
    end
  end
end
