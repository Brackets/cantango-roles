require 'spec_helper'
require 'fixtures/models'
require 'cantango/rspec'

CanTango.configure do |config|
  config.permission_engine.set :off
  config.permit_engine.set :on
  config.categories.register :blog_items => [Article, Post]
end


class UserRolePermit < CanTango::RolePermit
  def initialize ability
    super
  end

  protected

  def static_rules
    can :read, Comment
  end
end

class AdminRolePermit < CanTango::RolePermit
  def initialize ability
    super
  end

  protected

  def static_rules
    can :read, Post
  end
end


describe CanTango::Filter::Role do
  describe 'roles filter - exclude :user' do
    let (:user) do
      User.new 'stan', 'stan@gmail.com'
    end

    let (:user_account) do
      ua = UserAccount.new user, :roles => [:user, :admin], :role_groups => [:admins]
      user.account = ua
    end

    before do
      CanTango.config.roles.exclude :user
      CanTango.config.categories.register :blog_items => [Article, Post]

      @ability = CanTango::Ability.new user_account
    end

    after do
      CanTango.config.clear!
    end

    subject { @ability }
      specify { @ability.should be_allowed_to(:read, Post)}

      specify { @ability.should_not be_allowed_to(:read, Comment)}
      specify { @ability.should_not be_allowed_to(:write, Article)}
  end
end

describe CanTango::Filter::Role do
  describe 'roles filter - only :user' do
    let (:user) do
      User.new 'stan', 'stan@gmail.com'
    end

    let (:user_account) do
      ua = UserAccount.new user, :roles => [:user, :admin], :role_groups => [:admins, :editors]
      user.account = ua
    end

    before do
      CanTango.config.categories.register :blog_items => [Article, Post]
      CanTango.config.roles.only :user
      @ability = CanTango::Ability.new user_account
    end

    after do
      CanTango.config.clear!
    end

    subject { @ability }
      specify { @ability.should be_allowed_to(:read, Comment)}
      specify { @ability.should be_allowed_to(:write, Article)}

      specify { @ability.should be_allowed_to(:publish, Post)}

      specify { @ability.should_not be_allowed_to(:publish, Article)}
   end
end
