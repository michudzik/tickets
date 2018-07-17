require 'rails_helper'

RSpec.describe Department, type: :model do
  
  describe 'should have proper attributes' do
    it 'should have proper attributes' do
      expect(subject.attributes).to include('department_name')
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:department_name) }
    it { should validate_length_of(:department_name).is_at_most(40) }
  end

end