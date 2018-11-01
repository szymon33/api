class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    !user.nil?
  end

  def show?
    index?
  end

  def update?
    return true if user.admin?
    return true if user && record.creator == user
    false
  end

  def destroy?
    update?
  end

  def like?
    !user.nil?
  end
end
