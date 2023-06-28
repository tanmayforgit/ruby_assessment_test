class User < ApplicationRecord
  enum kind: { student: 0, teacher: 1, teaching_student: 2 }

  has_many :enrollments
  has_many :teachers, through: :enrollments
  has_many :programs, through: :enrollments
  has_many :favorite_enrollments, -> { where(favorite: true) }, class_name: 'Enrollment'
  has_many :favorite_teachers, through: :favorite_enrollments, source: :teacher
  has_many :as_teacher_enrollments, class_name: 'Enrollment', foreign_key: :teacher_id

  validate :teaching_enrollment_absence, if: :student?
  validate :enrollment_absence, if: :teacher?

  def classmates
    User.where(kind: :student)
        .where(id: similar_enrollments.pluck(:user_id)
      )
  end

  private

  def enrollment_absence
    if enrollments.any?
      errors.add(:kind, 'can not be teacher because is studying in at least one program')
    end
  end

  def teaching_enrollment_absence
    if as_teacher_enrollments.any?
      errors.add(:kind, 'can not be student because is teaching in at least one program')
    end
  end

  def similar_enrollments
    Enrollment.of_program(programs)
              .of_teacher(teachers)
              .where.not(user: self)
  end

end
