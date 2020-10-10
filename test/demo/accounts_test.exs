defmodule Demo.AccountsTest do
  use Demo.DataCase

  alias Demo.Accounts

  describe "users" do
    alias Demo.Accounts.User

    @valid_attrs %{active: true, age: 42, bio: "some bio", birthday: ~D[2010-04-17], name: "some name", pet: "some pet", start_time: ~T[14:00:00], started_at: ~N[2010-04-17 14:00:00]}
    @update_attrs %{active: false, age: 43, bio: "some updated bio", birthday: ~D[2011-05-18], name: "some updated name", pet: "some updated pet", start_time: ~T[15:01:01], started_at: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{active: nil, age: nil, bio: nil, birthday: nil, name: nil, pet: nil, start_time: nil, started_at: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.active == true
      assert user.age == 42
      assert user.bio == "some bio"
      assert user.birthday == ~D[2010-04-17]
      assert user.name == "some name"
      assert user.pet == "some pet"
      assert user.start_time == ~T[14:00:00]
      assert user.started_at == ~N[2010-04-17 14:00:00]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.active == false
      assert user.age == 43
      assert user.bio == "some updated bio"
      assert user.birthday == ~D[2011-05-18]
      assert user.name == "some updated name"
      assert user.pet == "some updated pet"
      assert user.start_time == ~T[15:01:01]
      assert user.started_at == ~N[2011-05-18 15:01:01]
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
