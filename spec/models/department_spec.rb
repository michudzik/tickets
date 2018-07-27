require 'rails_helper'

RSpec.describe Department, type: :model do
  
  describe 'should have proper attributes' do
    it 'should have proper attributes' do
      expect(subject.attributes).to include('name')
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(40) }
  end

  describe 'relations' do
    it { should have_many(:tickets) }
  end

end