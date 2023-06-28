FactoryBot.define do
  factory :program do
    name { "program_#{rand(1_000_000)}" }
  end
end
