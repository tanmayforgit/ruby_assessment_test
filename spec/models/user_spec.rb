require 'rails_helper'
RSpec.describe User, type: :model do
  describe 'Associations' do
    describe 'teachers related associations' do
      let(:student) { create(:student) }
      let(:other_student) { create(:student) }
      let(:teacher1) { create(:teacher) }
      let(:teacher2) { create(:teacher) }
      let(:other_teacher) { create(:teacher) }
      let(:program1) { create(:program) }
      let(:program2) { create(:program) }

      before do
        # We will enroll the student under some program
        # under teacher1 and teacher2. We will enroll
        # other_student under other_student under same program
        create(:enrollment,
          user: student,
          teacher: teacher1,
          program: program1
        )
        create(:enrollment,
          user: student,
          teacher: teacher2,
          favorite: true,
          program: program2
        )
        create(:enrollment,
          user: other_student,
          teacher: other_teacher,
          program: program2
        )
      end

      describe '#teachers' do
        subject { student.teachers }
        it 'Returns all the users who act as teachers via any enrollment' do
          expect(subject.count).to eq(2)
          expect(subject).to include(teacher1)
          expect(subject).to include(teacher2)
        end
      end

      describe '#favorite_teachers' do
        subject { student.favorite_teachers }
        it 'Returns only those users who act as teacher via an enrollment marked as favorite' do
          expect(subject.size).to eq(1)
          expect(subject).to include(teacher2)
        end
      end
    end

    describe 'classmates' do
      let(:program1) { create(:program) }
      let(:program2) { create(:program) }
      let(:teacher1) { create(:teacher) }
      let(:teacher2) { create(:teacher) }

      let!(:students_with_matching_teacher_and_program) do
        3.times.map do
          create(:student).tap do |student|
            create(:enrollment,
              user: student,
              teacher: teacher1,
              program: program1
            )
          end
        end
      end

      let!(:student_with_matching_program) do
        create(:student).tap do |student|
          create(:enrollment,
            user: student,
            teacher: teacher2,
            program: program1
          )
        end
      end

      let!(:student_with_matching_teacher) do
        create(:student).tap do |student|
          create(:enrollment,
            user: student,
            teacher: teacher1,
            program: program2
          )
        end
      end

      let(:student) { students_with_matching_teacher_and_program.first }

      subject { student.classmates }
      it 'Returns those users who have at least one enrollment with matching teacher and program' do
        expect(subject.size).to eq(2)
        expect(subject).to include(students_with_matching_teacher_and_program.second)
        expect(subject).to include(students_with_matching_teacher_and_program.third)
      end
    end
  end

  describe '#update' do
    context 'user is a teacher trying to be student' do
      let(:user) { create(:teacher) }
      subject { user.kind = User.kinds[:student]; user.save }
      context 'user does not have any teaching responsibilities' do
        it 'Succeeds' do
          expect(subject).to be_truthy
          expect(user.reload.kind).to eq('student')
        end
      end

      context 'user has teaching responsibilities' do
        let(:program) { create(:program) }
        let(:student) { create(:student) }

        before do
          create(:enrollment,
            user: student,
            program: program,
            teacher: user
          )
        end

        it 'is not allowed' do
          expect(subject).to be_falsey
          expect(user.errors[:kind]).to eq(['can not be student because is teaching in at least one program'])
        end
      end
    end

    context 'user is a student trying to be teacher' do
      let(:user) { create(:teacher) }
      subject { user.kind = User.kinds[:teacher]; user.save }
      context 'user does not have any enrollments' do
        it 'Succeeds' do
          expect(subject).to be_truthy
          expect(user.reload.kind).to eq('teacher')
        end
      end

      context 'user has enrollments' do
        let(:program) { create(:program) }
        let(:teacher) { create(:teacher) }

        before do
          create(:enrollment,
            user: user,
            program: program,
            teacher: teacher
          )
        end

        it 'is not allowed' do
          expect(subject).to be_falsey
          expect(user.errors[:kind]).to eq(['can not be teacher because is studying in at least one program'])
        end
      end
    end
  end
end