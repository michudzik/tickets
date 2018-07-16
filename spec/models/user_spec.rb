require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'attributes' do
    it 'should have proper attributes' do
      expect(subject.attributes).to include('first_name', 'last_name')
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

end
