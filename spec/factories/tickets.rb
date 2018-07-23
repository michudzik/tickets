FactoryBot.define do
	factory :ticket do |ticket|
		ticket.title	{ Faker::Name.name }
		ticket.note		{ Faker::Lorem.sentences(3) }
		user
		association :department, :it
    	association :status, :open
	end
end