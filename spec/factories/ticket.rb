FactoryBot.define do
	factory :ticket do |ticket|
		ticket.title	'title'
		ticket.note		'note'
		ticket.status 	'status'
		user
		department
	end
end