class Enrollment < ApplicationRecord
  belongs_to :user, foreign_key: :user_id
  belongs_to :teacher, foreign_key: :teacher_id, class_name: 'User'
  belongs_to :program

  class << self
    def of_program(program)
      where(program: program)
    end

    def of_teacher(teacher)
      where(teacher: teacher)
    end
  end
end
