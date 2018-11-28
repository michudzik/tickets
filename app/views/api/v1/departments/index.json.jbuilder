json.departments @departments do |department|
  json.id department[1]
  json.name department[0]
end
