FactoryBot.define do
  factory :student, class: User do
    name { "user_#{rand(1_000_000)}" }
    kind { User.kinds[:student] }
    age { rand(10..110) }
  end

  factory :teacher, class: User do
    name { "teacher_#{rand(1_000_000)}" }
    kind { User.kinds[:teacher] }
    age { rand(10..110) }
  end
end
