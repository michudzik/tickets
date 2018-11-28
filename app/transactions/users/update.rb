module Users
  class Update < ApplicationTransaction
    try :assign_object, catch: ActiveRecord::RecordNotFound
    map :assign_attributes
    check :validate
    try :persist, catch: ActiveRecord::ActiveRecordError

    private

    def assign_object(id)
      ::User.find(id)
    end

    def assign_attributes(user)
      user.assign_attributes(current_params)
      user
    end

    def validate(user)
      user.valid?
    end

    def persist(user)
      user.save!
      user
    end
  end
end
