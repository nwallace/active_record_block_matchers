class Person < ActiveRecord::Base
  # attributes :first_name, :last_name, :created_at, :updated_at
  def full_name
    "#{first_name} #{last_name}"
  end
end
