`createdb acts_as_readable_test`
require 'spec_helper'

describe 'acts_as_readable' do
  before(:each) do
    @comment = Comment.create
    @user = User.create
  end

  describe "the unread scope" do
    it "should return records without readings if the user hasn't 'read all'" do
      Comment.unread_by(@user).exists?(@comment).should be_true
    end

    it "should return records explicitly marked as unread if the user hasn't 'read all'" do
      @comment.unread_by! @user
      Comment.unread_by(@user).exists?(@comment).should be_true
    end

    it "should return records explicitly marked as unread if the user has 'read all' before the record was marked unread" do
      Comment.read_by! @user
      @comment.unread_by! @user
      Comment.unread_by(@user).exists?(@comment).should be_true
    end

    it "should not return records explicitly marked as unread if the user has 'read all' after the record was marked unread" do
      @comment.unread_by! @user
      Comment.read_by! @user
      Comment.unread_by(@user).exists?(@comment).should be_false
    end
  end

  describe "the read scope" do
    it "should return records without readings if the user has 'read all' since the last time the record was updated" do
      Comment.read_by! @user
      Comment.read_by(@user).exists?(@comment).should be_true
    end

    it "should return records explicitly marked as read if the user hasn't 'read all'" do
      @comment.read_by! @user
      Comment.read_by(@user).exists?(@comment).should be_true
    end

    it "should return records explicitly marked as read if the user has 'read all' before the record was marked unread" do
      Comment.read_by! @user
      @comment.read_by! @user
      Comment.read_by(@user).exists?(@comment).should be_true
    end

    it "should return records explicitly marked as unread if the user has 'read all' after the record was marked unread" do
      @comment.unread_by! @user
      Comment.read_by! @user
      Comment.read_by(@user).exists?(@comment).should be_true
    end
  end

  describe "when checking a specific record for read_by?" do
    it "should return true if the record hasn't explicitly been read, but the user has 'read all' since the record was created" do
      Comment.read_by! @user
      @comment.read_by?(@user).should be_true
    end

    it "should return true if the record hasn't explicitly been read and the user has 'read all' since the record was created but not since it was updated" do
      Comment.read_by! @user
      @comment.touch
      @comment.read_by?(@user).should be_true
    end

    it "should return true if the record has been explicitly marked as read and the user hasn't 'read all'" do
      @comment.read_by! @user
      @comment.read_by?(@user).should be_true
    end

    it "should return false if the user 'read all' before and then marked the record as unread" do
      Comment.read_by! @user
      @comment.unread_by! @user
      @comment.read_by?(@user).should be_false
    end

    it "should return true if the user has explicitly marked it as unread and then 'reads all'" do
      @comment.unread_by! @user
      Comment.read_by! @user
      @comment.read_by?(@user).should be_true
    end
  end

  describe "when checking a specific record for latest_update_read_by?" do
    it "should return true if the record hasn't explicitly been read, but the user has 'read all' since the record was updated" do
      Comment.read_by! @user
      @comment.latest_update_read_by?(@user).should be_true
    end

    it "should return false if the record hasn't explicitly been read and the user has 'read all' since the record was created but not since it was updated" do
      Comment.read_by! @user
      @comment.touch
      @comment.latest_update_read_by?(@user).should be_false
    end

    it "should return true if the record has been explicitly marked as read and the user hasn't 'read all'" do
      @comment.read_by! @user
      @comment.latest_update_read_by?(@user).should be_true
    end

    it "should return false if the user 'read all' before and then marked the record as unread" do
      Comment.read_by! @user
      @comment.unread_by! @user
      @comment.latest_update_read_by?(@user).should be_false
    end

    it "should return true if the user has explicitly marked it as unread and then 'reads all'" do
      @comment.unread_by! @user
      Comment.read_by! @user
      @comment.latest_update_read_by?(@user).should be_true
    end

    it "should return false if the user 'read all' before and then marked the record as unread using cached readings" do
      Comment.read_by! @user
      @comment.unread_by! @user
      Comment.cache_readings_for([@comment], @user)
      @comment.latest_update_read_by?(@user).should be_false
    end
  end
end
`dropdb acts_as_readable_test`