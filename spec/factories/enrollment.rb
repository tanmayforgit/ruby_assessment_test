FactoryBot.define do
  factory :enrollment do
    teacher { create(:teacher) }
    user { create(:student) }
    program { create(:program) }
    favorite { false }
  end
end
