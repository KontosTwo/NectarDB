defmodule ChangelogTest do
  use ExUnit.Case, async: false

  alias NectarNode.Changelog

  setup do
    start_supervised!(Changelog)
    :ok
  end

  describe "adding and retrieving changelogs" do
    test "succeeds for one changelog" do
      Changelog.add_changelog({1,[{:write,1,2},{:delete,1}]})
      assert [{1,[{:write,1,2},{:delete,1}]},{0,[]}] == Changelog.get_changelogs()
    end

    test "succeeds for multiple changelogs" do
      Changelog.add_changelog({1,[{:write,1,2},{:delete,1}]})
      Changelog.add_changelog({2,[{:write,1,2},{:delete,1}]})      
      assert [
        {2,[{:write,1,2},{:delete,1}]},
        {1,[{:write,1,2},{:delete,1}]},
        {0,[]}        
      ] == Changelog.get_changelogs()
    end
  end

  describe "rollback changelog" do
    test "rollback one changelog" do
      Changelog.add_changelog({1,[{:write,1,2}]})
      Changelog.rollback_changelog()
      assert [{0,[]}] == Changelog.get_changelogs()
    end

    test "rollback on empty changelog" do
      Changelog.rollback_changelog()
      assert [] == Changelog.get_changelogs()
    end
  end
end