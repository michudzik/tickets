module Users
  class DeactivateAccount < ApplicationTransaction
    try :assign_object, catch: ActiveRecord::RecordNotFound
    check :same_user
    try :deactivate, catch: ActiveRecord::ActiveRecordError

    private

    def assign_object(id)
      ::User.find(id)
    end

    def same_user(user)
      !user.same_user?(current_user.id)
    end

    def deactivate(user)
      user.lock_access!
      user
    end
  end
end
